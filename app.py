from flask import Flask, request, jsonify, render_template, redirect, url_for
from flask_mysqldb import MySQL
from flask_bcrypt import Bcrypt
from flask_jwt_extended import JWTManager, create_access_token, jwt_required, get_jwt_identity
from flask_cors import CORS
from flask_wtf.csrf import CSRFProtect
from datetime import datetime, timedelta
import MySQLdb.cursors

# Initialize app
app = Flask(__name__)

# Config
app.config['SECRET_KEY'] = 'super-secret-key'  # Needed for CSRF + JWT
app.config['JWT_SECRET_KEY'] = 'jwt-secret-key'

# MySQL configuration
app.config['MYSQL_HOST'] = 'localhost'
app.config['MYSQL_USER'] = 'root'
app.config['MYSQL_PASSWORD'] = 'Wayne#12'   # set your MySQL password
app.config['MYSQL_DB'] = 'school_lms'

# Initialize extensions
mysql = MySQL(app)
bcrypt = Bcrypt(app)
jwt = JWTManager(app)
CORS(app)
csrf = CSRFProtect(app)


# -------------------------
# Default route (welcome)
# -------------------------
@app.route('/')
def welcome():
    return render_template('welcome.html')


# -------------------------
# Render HTML pages
# -------------------------
@app.route('/register', methods=['GET'])
def register_page():
    return render_template('register.html')


@app.route('/login', methods=['GET'])
def login_page():
    return render_template('frontendlogin.html')


@app.route('/dashboard', methods=['GET'])
@jwt_required(optional=True)
def dashboard():
    current_user = get_jwt_identity()
    return render_template('dashboard.html', user=current_user)


# -------------------------
# API routes (CSRF exempt)
# -------------------------
@csrf.exempt
@app.route('/api/register', methods=['POST'])
def api_register():
    data = request.get_json()
    fullname = data.get('fullname')
    email = data.get('email')
    password = data.get('password')
    role = data.get('role')

    if not fullname or not email or not password or not role:
        return jsonify({"error": "All fields are required"}), 400

    cursor = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
    cursor.execute("SELECT * FROM users WHERE email=%s", (email,))
    existing_user = cursor.fetchone()

    if existing_user:
        return jsonify({"error": "User already exists"}), 400

    password_hash = bcrypt.generate_password_hash(password).decode('utf-8')
    cursor.execute(
        "INSERT INTO users (email, password_hash, role, created_at, is_active) VALUES (%s, %s, %s, %s, %s)",
        (email, password_hash, role, datetime.utcnow(), True)
    )
    mysql.connection.commit()
    cursor.close()

    return jsonify({"message": "User registered successfully"}), 201


@csrf.exempt
@app.route('/api/login', methods=['POST'])
def api_login():
    data = request.get_json()
    email = data.get('email')
    password = data.get('password')

    if not email or not password:
        return jsonify({"error": "Email and password required"}), 400

    cursor = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
    cursor.execute("SELECT * FROM users WHERE email=%s", (email,))
    user = cursor.fetchone()
    cursor.close()

    if user and bcrypt.check_password_hash(user['password_hash'], password):
        access_token = create_access_token(identity=user['email'], expires_delta=timedelta(hours=1))

        # Update last_login
        cursor = mysql.connection.cursor()
        cursor.execute("UPDATE users SET last_login=%s WHERE id=%s", (datetime.utcnow(), user['id']))
        mysql.connection.commit()
        cursor.close()

        return jsonify({"message": "Login successful", "token": access_token}), 200
    else:
        return jsonify({"error": "Invalid email or password"}), 401


# -------------------------
# Protected API Example
# -------------------------
@app.route('/api/profile', methods=['GET'])
@jwt_required()
def profile():
    current_user = get_jwt_identity()
    return jsonify({"email": current_user, "status": "active"}), 200


# -------------------------
# Error handlers
# -------------------------
@app.errorhandler(404)
def not_found(e):
    return jsonify({"error": "Not found"}), 404


@app.errorhandler(500)
def server_error(e):
    return jsonify({"error": "Server error"}), 500


# -------------------------
# Run app
# -------------------------
if __name__ == '__main__':
    app.run(debug=True)
