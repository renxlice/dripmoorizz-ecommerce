<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Login | DripmooRizz</title>

    <!-- Bootstrap & Google Fonts -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@500;600&display=swap" rel="stylesheet">

    <style>
        body {
            background: url('images/Milk-Protein-Panel.jpg') no-repeat center center fixed;
            background-size: cover;
            font-family: 'Poppins', sans-serif;
            min-height: 100vh;
            margin: 0;
            display: flex;
            align-items: center;
            justify-content: center;
            position: relative;
        }
        body::before {
            content: "";
            position: absolute;
            top: 0; left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0, 0, 0, 0.5);
            z-index: 0;
        }
        .card {
            position: relative;
            z-index: 1;
            background: rgba(255, 255, 255, 0.1);
            backdrop-filter: blur(12px);
            color: #fff;
            border-radius: 20px;
            padding: 40px 30px;
            max-width: 420px;
            width: 100%;
            box-shadow: 0 15px 30px rgba(0,0,0,0.3);
            text-align: center;
        }
        .form-control {
            border-radius: 10px;
            background-color: rgba(255, 255, 255, 0.8);
            border: none;
        }
        .form-control:focus {
            box-shadow: none;
            outline: none;
        }
        .btn-custom {
            background: linear-gradient(to right, #6c63ff, #574b90);
            color: #fff;
            border: none;
            border-radius: 10px;
            padding: 10px 20px;
            font-weight: 600;
            text-transform: uppercase;
            transition: 0.3s;
        }
        .btn-custom:hover {
            background: linear-gradient(to right, #574b90, #6c63ff);
        }
        .form-label {
            font-weight: 500;
            color: #fff;
        }
        .btn-cancel {
            background-color: transparent;
            color: white;
            border: 2px solid #fff;
            font-weight: 600;
            border-radius: 10px;
            padding: 10px;
            transition: 0.3s ease;
        }
        .btn-cancel:hover {
            background-color: rgba(255, 255, 255, 0.2);
            color: #fff;
        }
        a {
            color: #ffc107;
            text-decoration: none;
        }
        a:hover {
            color: #e0a800;
        }
        h3 {
            font-weight: 600;
            margin-bottom: 25px;
            color: #fff;
        }
        .google-btn {
            margin-top: 20px;
        }
    </style>
</head>
<body>
<div class="card">
    <h3>Login DripmooRizz</h3>

    <%-- Tampilkan pesan error jika login gagal --%>
    <%
        String error = request.getParameter("error");
        if ("invalid_google_data".equals(error)) {
    %>
    <div class="alert alert-danger" role="alert">
        Gagal login dengan Google. Silakan coba lagi.
    </div>
    <% } %>

    <form action="login-process.jsp" method="post">
        <div class="mb-3 text-start">
            <label for="email" class="form-label">Email</label>
            <input type="email" class="form-control" name="email" id="email" required>
        </div>
        <div class="mb-4 text-start">
            <label for="password" class="form-label">Password</label>
            <input type="password" class="form-control" name="password" id="password" required>
        </div>
        <div class="d-flex justify-content-between gap-2">
            <button type="submit" class="btn btn-custom w-50">Login</button>
            <a href="home.jsp" class="btn btn-cancel w-50">Cancel</a>
        </div>
    </form>

    <!-- Firebase Google Login -->
    <div class="google-btn mt-4">
        <a href="#" id="googleLoginBtn" class="btn btn-light w-100 d-flex align-items-center justify-content-center">
            <img src="https://developers.google.com/identity/images/g-logo.png" style="width:20px; margin-right:10px;" alt="Google Logo" />
            Sign in with Google
        </a>
    </div>

    <p class="mt-3">Don't have an account yet? <a href="tb1.html">Register here</a></p>
</div>

<!-- JS & Firebase -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://www.gstatic.com/firebasejs/9.22.2/firebase-app-compat.js"></script>
<script src="https://www.gstatic.com/firebasejs/9.22.2/firebase-auth-compat.js"></script>

<script>
    // Firebase config
    const firebaseConfig = {
        apiKey: "AIzaSyDb2jVv9nLgJec6l85WnwR6MTh_ihcintA",
        authDomain: "dripmoorizz-b9a80.firebaseapp.com",
        projectId: "dripmoorizz-b9a80",
        storageBucket: "dripmoorizz-b9a80.appspot.com",
        messagingSenderId: "844266499383",
        appId: "1:844266499383:web:1a0e0a97617e6f602dbeb2"
    };

    firebase.initializeApp(firebaseConfig);
    const auth = firebase.auth();
    const provider = new firebase.auth.GoogleAuthProvider();

    document.getElementById("googleLoginBtn").addEventListener("click", function (e) {
        e.preventDefault();

        auth.signInWithPopup(provider)
            .then((result) => {
                const user = result.user;

                // Buat form POST ke servlet agar session disimpan
                const form = document.createElement("form");
                form.method = "POST";
                form.action = "GoogleLoginServlet";

                const nameInput = document.createElement("input");
                nameInput.type = "hidden";
                nameInput.name = "nama";
                nameInput.value = user.displayName;

                const emailInput = document.createElement("input");
                emailInput.type = "hidden";
                emailInput.name = "email";
                emailInput.value = user.email;

                form.appendChild(nameInput);
                form.appendChild(emailInput);
                document.body.appendChild(form);
                form.submit();
            })
            .catch((error) => {
                console.error("Login gagal:", error);
                alert("Login gagal: " + error.message);
            });
    });
</script>
</body>
</html>
