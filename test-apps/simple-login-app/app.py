from flask import Flask, request, render_template, redirect, session, url_for

app = Flask(__name__)
app.secret_key = 'test-secret-key-for-demo'

# Test credentials
VALID_USERS = {
    'testuser': 'testpass123',
    'admin': 'password',
    'demo': 'demo123'
}

@app.route('/')
def index():
    if 'logged_in' in session and session['logged_in']:
        return render_template('dashboard.html', username=session.get('username', 'User'))
    return redirect(url_for('login'))

@app.route('/login', methods=['GET', 'POST'])
def login():
    error = None
    if request.method == 'POST':
        username = request.form.get('username', '').strip()
        password = request.form.get('password', '')
        
        if username in VALID_USERS and VALID_USERS[username] == password:
            session['logged_in'] = True
            session['username'] = username
            return redirect(url_for('dashboard'))
        else:
            error = 'Invalid credentials. Please try again.'
    
    return render_template('login.html', error=error)

@app.route('/dashboard')
def dashboard():
    if 'logged_in' not in session or not session['logged_in']:
        return redirect(url_for('login'))
    return render_template('dashboard.html', username=session.get('username', 'User'))

@app.route('/logout')
def logout():
    session.clear()
    return redirect(url_for('login'))

@app.route('/health')
def health():
    return 'OK', 200

@app.route('/api/status')
def api_status():
    if 'logged_in' in session and session['logged_in']:
        return {'status': 'authenticated', 'user': session.get('username')}
    return {'status': 'unauthenticated'}, 401

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=False)
