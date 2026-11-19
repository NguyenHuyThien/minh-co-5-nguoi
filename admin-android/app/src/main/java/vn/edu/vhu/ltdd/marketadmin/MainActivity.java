package vn.edu.vhu.ltdd.marketadmin;

import android.os.Bundle;
import androidx.annotation.NonNull;
import androidx.appcompat.app.ActionBarDrawerToggle;
import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.widget.Toolbar;
import androidx.core.view.GravityCompat;
import androidx.drawerlayout.widget.DrawerLayout;
import androidx.fragment.app.Fragment;
import com.google.android.material.navigation.NavigationView;
import android.view.MenuItem;

public class MainActivity extends AppCompatActivity implements NavigationView.OnNavigationItemSelectedListener {

    private DrawerLayout drawerLayout;
    private Toolbar toolbar;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        toolbar = findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);

        drawerLayout = findViewById(R.id.drawer_layout);
        NavigationView navigationView = findViewById(R.id.nav_view);
        navigationView.setNavigationItemSelectedListener(this);

        // Tạo nút 3 gạch (Hamburger) trên Toolbar để mở thanh bar
        ActionBarDrawerToggle toggle = new ActionBarDrawerToggle(
                this, drawerLayout, toolbar,
                R.string.navigation_drawer_open, R.string.navigation_drawer_close);
        drawerLayout.addDrawerListener(toggle);
        toggle.syncState();

        // Mặc định mở trang đầu tiên (Duyệt hồ sơ gian hàng) khi mới vào app
        if (savedInstanceState == null) {
            getSupportFragmentManager().beginTransaction()
                    .replace(R.id.fragment_container, new SoDoChoFragment())
                    .commit();
            navigationView.setCheckedItem(R.id.nav_so_do_cho);
            toolbar.setTitle("Quản lý sơ đồ chợ");
        }
    }

    @Override
    public boolean onNavigationItemSelected(@NonNull MenuItem item) {
        Fragment selectedFragment = null;
        String title = "";
        int id = item.getItemId();

        if (id == R.id.nav_duyet_ho_so) {
            selectedFragment = new DuyetHoSoFragment();
            title = "Duyệt hồ sơ gian hàng";
        } else if (id == R.id.nav_so_do_cho) {
            selectedFragment = new SoDoChoFragment();
            title = "Quản lý sơ đồ chợ";
        } else if (id == R.id.nav_tieu_thuong) {
            selectedFragment = new TieuThuongFragment();
            title = "Quản lý tiểu thương";
        } else if (id == R.id.nav_duyet_mat_hang) {
            selectedFragment = new DuyetMatHangFragment();
            title = "Duyệt mặt hàng";
        } else if (id == R.id.nav_don_di_cho) {
            selectedFragment = new DonDiChoFragment();
            title = "Theo dõi đơn đi chợ hộ";
        } else if (id == R.id.nav_khieu_nai) {
            selectedFragment = new KhieuNaiFragment();
            title = "Xử lý khiếu nại";
        } else if (id == R.id.nav_bao_cao) {
            selectedFragment = new BaoCaoFragment();
            title = "Báo cáo thống kê";
        }

        if (selectedFragment != null) {
            getSupportFragmentManager().beginTransaction()
                    .replace(R.id.fragment_container, selectedFragment)
                    .commit();
            toolbar.setTitle(title);
        }

        drawerLayout.closeDrawer(GravityCompat.START);
        return true;
    }
}
