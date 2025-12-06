from flask import Flask, render_template, request
import subprocess
import os

app = Flask(__name__)

@app.route('/', methods=['GET', 'POST'])
def index():
    result = ""
    expression = ""

    if request.method == 'POST':
        expression = request.form['expression']
        try:
            calc_path = os.path.join('calc_backend', 'calc_exec')
            process = subprocess.run(
                [calc_path, expression],
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                text=True
            )

            if process.stdout.strip():
                result = process.stdout.strip().replace("Result:", "").strip()
            else:
                result = process.stderr.strip() or "Invalid Expression"
        except Exception as e:
            result = f"Error: {e}"

    return render_template('index.html', result=result, expression=expression)

if __name__ == '__main__':
    app.run(debug=True)
