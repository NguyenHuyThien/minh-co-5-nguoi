package vn.edu.vhu.ltdd.marketadmin;

import android.graphics.Color;
import android.os.Bundle;
import android.util.Log;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;
import android.widget.Toast;
import androidx.appcompat.app.AppCompatActivity;

public class LoginActivity extends AppCompatActivity {

    private EditText edtEmail, edtPassword;
    private Button btnLogin;
    private TextView tvStatus;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_login);

        edtEmail = findViewById(R.id.edtEmail);
        edtPassword = findViewById(R.id.edtPassword);
        btnLogin = findViewById(R.id.btnLogin);
        tvStatus = findViewById(R.id.tvStatus);

        btnLogin.setOnClickListener(v -> {
            String email = edtEmail.getText().toString().trim();
            String password = edtPassword.getText().toString().trim();

            Log.d("LOGIN_TEST", "Da bam nut! Email=" + email + ", Pass=" + password);

            if (email.isEmpty() && password.isEmpty()) {
                tvStatus.setTextColor(Color.RED);
                tvStatus.setText("Vui lòng nhập đầy đủ Email và Mật khẩu!");
                return;
            }

            if (email.isEmpty()) {
                tvStatus.setTextColor(Color.RED);
                tvStatus.setText("Vui lòng nhập email!");
                return;
            }

            if (password.isEmpty()) {
                tvStatus.setTextColor(Color.RED);
                tvStatus.setText("Vui lòng nhập mật khẩu!");
                return;
            }

            if (email.equals("admin@cho.vn") && password.equals("123456")) {
                tvStatus.setTextColor(Color.parseColor("#2E7D32"));
                tvStatus.setText("Đăng nhập thành công!");
                Toast.makeText(this, "Đăng nhập thành công!", Toast.LENGTH_SHORT).show();
            } else {
                tvStatus.setTextColor(Color.RED);
                tvStatus.setText("Sai tài khoản hoặc mật khẩu!");
            }
        });
    }
}