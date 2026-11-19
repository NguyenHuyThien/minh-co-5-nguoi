package vn.edu.vhu.ltdd.marketadmin;

import android.app.AlertDialog;
import android.content.Context;
import android.graphics.Color;
import android.os.Bundle;
import android.text.Editable;
import android.text.TextWatcher;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.inputmethod.EditorInfo;
import android.view.inputmethod.InputMethodManager;
import android.widget.ArrayAdapter;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.Spinner;
import android.widget.TextView;
import android.widget.Toast;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.cardview.widget.CardView;
import androidx.fragment.app.Fragment;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import com.google.android.material.chip.ChipGroup;
import com.google.android.material.floatingactionbutton.FloatingActionButton;
import java.text.Normalizer;
import java.util.ArrayList;
import java.util.List;
import java.util.regex.Pattern;

public class SoDoChoFragment extends Fragment {

    private RecyclerView rvSoDoSap;
    private SapHangAdapter adapter;
    private List<SapHang> tatCaSap = new ArrayList<>();

    private CardView cardStatDaThue, cardStatTrong, cardStatKhoa;
    private TextView tvStatDaThue, tvStatTrong, tvStatKhoa, tvKhongCoKetQua;
    private Integer trangThaiLoc = null;

    private String khuVucHienTai = "Tất cả";
    private String tuKhoaHienTai = "";

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_so_do_cho, container, false);

        rvSoDoSap = view.findViewById(R.id.rvSoDoSap);
        ChipGroup chipGroup = view.findViewById(R.id.chipGroupKhuVuc);
        EditText etTimKiem = view.findViewById(R.id.etTimKiemSap);
        ImageView btnXoaTimKiem = view.findViewById(R.id.btnXoaTimKiem);
        FloatingActionButton fabThemSap = view.findViewById(R.id.fabThemSap);

        cardStatDaThue = view.findViewById(R.id.cardStatDaThue);
        cardStatTrong = view.findViewById(R.id.cardStatTrong);
        cardStatKhoa = view.findViewById(R.id.cardStatKhoa);
        tvStatDaThue = view.findViewById(R.id.tvStatDaThue);
        tvStatTrong = view.findViewById(R.id.tvStatTrong);
        tvStatKhoa = view.findViewById(R.id.tvStatKhoa);
        tvKhongCoKetQua = view.findViewById(R.id.tvKhongCoKetQua);

        taoDuLieuMau();

        rvSoDoSap.setLayoutManager(new LinearLayoutManager(getContext()));
        adapter = new SapHangAdapter(tatCaSap, this::hienDialogChiTietSap);
        rvSoDoSap.setAdapter(adapter);

        cardStatDaThue.setOnClickListener(v -> chonBoLocTrangThai(1));
        cardStatTrong.setOnClickListener(v -> chonBoLocTrangThai(0));
        cardStatKhoa.setOnClickListener(v -> chonBoLocTrangThai(-1));

        chipGroup.setOnCheckedStateChangeListener((group, checkedIds) -> {
            if (checkedIds.isEmpty()) return;
            int id = checkedIds.get(0);

            if (id == R.id.chipTatCa) khuVucHienTai = "Tất cả";
            else if (id == R.id.chipRauCu) khuVucHienTai = "Rau củ";
            else if (id == R.id.chipThitCa) khuVucHienTai = "Thịt cá";
            else if (id == R.id.chipDoKho) khuVucHienTai = "Đồ khô";
            else if (id == R.id.chipGiaDung) khuVucHienTai = "Đồ gia dụng";

            locDanhSach();
        });

        etTimKiem.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {}

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
                tuKhoaHienTai = boDauTiengViet(s.toString().trim());
                btnXoaTimKiem.setVisibility(s.length() > 0 ? View.VISIBLE : View.GONE);
                locDanhSach();
            }

            @Override
            public void afterTextChanged(Editable s) {}
        });

        btnXoaTimKiem.setOnClickListener(v -> {
            etTimKiem.setText("");
            etTimKiem.clearFocus();
            anBanPhim(etTimKiem);
        });

        etTimKiem.setOnEditorActionListener((v, actionId, event) -> {
            if (actionId == EditorInfo.IME_ACTION_SEARCH) {
                anBanPhim(etTimKiem);
                etTimKiem.clearFocus();
                return true;
            }
            return false;
        });

        fabThemSap.setOnClickListener(v -> hienDialogThemSap());

        locDanhSach();
        return view;
    }

    private void hienDialogThemSap() {
        if (getContext() == null) return;

        LinearLayout layout = new LinearLayout(getContext());
        layout.setOrientation(LinearLayout.VERTICAL);
        int pad = (int) (20 * getResources().getDisplayMetrics().density);
        layout.setPadding(pad, pad / 2, pad, 0);

        TextView tvLabelKhuVuc = new TextView(getContext());
        tvLabelKhuVuc.setText("Chọn khu vực:");
        tvLabelKhuVuc.setTextColor(Color.parseColor("#334155"));
        layout.addView(tvLabelKhuVuc);

        Spinner spKhuVuc = new Spinner(getContext());
        String[] dsKhuVuc = {"Rau củ", "Thịt cá", "Đồ khô", "Đồ gia dụng"};
        ArrayAdapter<String> spAdapter = new ArrayAdapter<>(getContext(), android.R.layout.simple_spinner_dropdown_item, dsKhuVuc);
        spKhuVuc.setAdapter(spAdapter);
        layout.addView(spKhuVuc);

        EditText etMaSap = new EditText(getContext());
        etMaSap.setHint("Mã sạp (VD: RC-04, TC-04...)");
        etMaSap.setSingleLine(true);
        layout.addView(etMaSap);

        EditText etTenTieuThuong = new EditText(getContext());
        etTenTieuThuong.setHint("Tên tiểu thương (bỏ trống nếu là sạp trống)");
        etTenTieuThuong.setSingleLine(true);
        layout.addView(etTenTieuThuong);

        AlertDialog dialog = new AlertDialog.Builder(getContext())
                .setTitle("Thêm vị trí sạp mới")
                .setView(layout)
                .setPositiveButton("Thêm sạp", null)
                .setNegativeButton("Hủy", null)
                .create();

        dialog.setOnShowListener(d -> dialog.getButton(AlertDialog.BUTTON_POSITIVE).setOnClickListener(v -> {
            String maSap = etMaSap.getText().toString().trim().toUpperCase();
            String khuVuc = spKhuVuc.getSelectedItem().toString();
            String tenTieuThuong = etTenTieuThuong.getText().toString().trim();

            if (maSap.isEmpty()) {
                etMaSap.setError("Vui lòng nhập mã sạp");
                return;
            }

            for (SapHang sap : tatCaSap) {
                if (sap.maSap.equalsIgnoreCase(maSap)) {
                    etMaSap.setError("Mã sạp " + maSap + " đã tồn tại");
                    return;
                }
            }

            int trangThai = tenTieuThuong.isEmpty() ? 0 : 1;
            if (tenTieuThuong.isEmpty()) {
                tenTieuThuong = "Trống";
            }

            tatCaSap.add(0, new SapHang(maSap, khuVuc, tenTieuThuong, trangThai));
            locDanhSach();
            rvSoDoSap.scrollToPosition(0);
            Toast.makeText(getContext(), "Đã thêm sạp " + maSap + " vào khu " + khuVuc, Toast.LENGTH_SHORT).show();
            dialog.dismiss();
        }));

        dialog.show();
    }

    private void hienDialogChiTietSap(SapHang sap) {
        if (getContext() == null) return;

        String[] cacTrangThai = {"Đã thuê (Đang hoạt động)", "Sạp trống", "Tạm khóa"};
        int mucHienTai = (sap.trangThai == 1) ? 0 : (sap.trangThai == 0) ? 1 : 2;

        AlertDialog dialog = new AlertDialog.Builder(getContext())
                .setTitle("Sạp " + sap.maSap + " • " + sap.khuVuc)
                .setSingleChoiceItems(cacTrangThai, mucHienTai, (d, which) -> {
                    if (which == 0) {
                        sap.trangThai = 1;
                        if (sap.tenTieuThuong.equals("Trống")) sap.tenTieuThuong = "Tiểu thương mới";
                    } else if (which == 1) {
                        sap.trangThai = 0;
                        sap.tenTieuThuong = "Trống";
                    } else {
                        sap.trangThai = -1;
                    }
                    locDanhSach();
                    d.dismiss();
                    Toast.makeText(getContext(), "Đã cập nhật trạng thái sạp " + sap.maSap, Toast.LENGTH_SHORT).show();
                })
                .setNeutralButton("Xóa sạp", (d, which) -> xacNhanXoaSap(sap))
                .setNegativeButton("Đóng", null)
                .create();

        dialog.setOnShowListener(d -> dialog.getButton(AlertDialog.BUTTON_NEUTRAL).setTextColor(Color.parseColor("#DC2626")));
        dialog.show();
    }

    private void xacNhanXoaSap(SapHang sap) {
        if (getContext() == null) return;

        new AlertDialog.Builder(getContext())
                .setTitle("Xác nhận xóa sạp")
                .setMessage("Bạn có chắc muốn xóa vị trí sạp " + sap.maSap + " (" + sap.khuVuc + ") khỏi sơ đồ chợ?")
                .setPositiveButton("Xóa", (dialog, which) -> {
                    tatCaSap.remove(sap);
                    locDanhSach();
                    Toast.makeText(getContext(), "Đã xóa sạp " + sap.maSap, Toast.LENGTH_SHORT).show();
                })
                .setNegativeButton("Hủy", null)
                .show();
    }

    private void anBanPhim(View view) {
        if (getContext() != null) {
            InputMethodManager imm = (InputMethodManager) getContext().getSystemService(Context.INPUT_METHOD_SERVICE);
            if (imm != null) {
                imm.hideSoftInputFromWindow(view.getWindowToken(), 0);
            }
        }
    }

    private String boDauTiengViet(String text) {
        String temp = Normalizer.normalize(text, Normalizer.Form.NFD);
        Pattern pattern = Pattern.compile("\\p{InCombiningDiacriticalMarks}+");
        return pattern.matcher(temp).replaceAll("")
                .replace('đ', 'd')
                .replace('Đ', 'D')
                .toLowerCase();
    }

    private void chonBoLocTrangThai(int trangThai) {
        if (trangThaiLoc != null && trangThaiLoc == trangThai) {
            trangThaiLoc = null;
        } else {
            trangThaiLoc = trangThai;
        }
        capNhatGiaoDienTheThongKe();
        locDanhSach();
    }

    private void capNhatGiaoDienTheThongKe() {
        cardStatDaThue.setCardElevation(trangThaiLoc != null && trangThaiLoc == 1 ? 8f : 0f);
        cardStatTrong.setCardElevation(trangThaiLoc != null && trangThaiLoc == 0 ? 8f : 0f);
        cardStatKhoa.setCardElevation(trangThaiLoc != null && trangThaiLoc == -1 ? 8f : 0f);

        cardStatDaThue.setAlpha(trangThaiLoc == null || trangThaiLoc == 1 ? 1.0f : 0.45f);
        cardStatTrong.setAlpha(trangThaiLoc == null || trangThaiLoc == 0 ? 1.0f : 0.45f);
        cardStatKhoa.setAlpha(trangThaiLoc == null || trangThaiLoc == -1 ? 1.0f : 0.45f);
    }

    private void locDanhSach() {
        List<SapHang> ketQua = new ArrayList<>();
        int demDaThue = 0, demTrong = 0, demKhoa = 0;

        for (SapHang sap : tatCaSap) {
            boolean khopKhuVuc = khuVucHienTai.equals("Tất cả") || sap.khuVuc.equals(khuVucHienTai);
            String maSapKhongDau = boDauTiengViet(sap.maSap);
            String tenKhongDau = boDauTiengViet(sap.tenTieuThuong);
            String khuVucKhongDau = boDauTiengViet(sap.khuVuc);

            boolean khopTuKhoa = tuKhoaHienTai.isEmpty()
                    || maSapKhongDau.contains(tuKhoaHienTai)
                    || tenKhongDau.contains(tuKhoaHienTai)
                    || khuVucKhongDau.contains(tuKhoaHienTai);

            if (khopKhuVuc && khopTuKhoa) {
                if (sap.trangThai == 1) demDaThue++;
                else if (sap.trangThai == 0) demTrong++;
                else demKhoa++;

                if (trangThaiLoc == null || sap.trangThai == trangThaiLoc) {
                    ketQua.add(sap);
                }
            }
        }

        tvStatDaThue.setText(demDaThue + " sạp");
        tvStatTrong.setText(demTrong + " sạp");
        tvStatKhoa.setText(demKhoa + " sạp");

        tvKhongCoKetQua.setVisibility(ketQua.isEmpty() ? View.VISIBLE : View.GONE);
        rvSoDoSap.setVisibility(ketQua.isEmpty() ? View.GONE : View.VISIBLE);

        adapter.updateData(ketQua);
    }

    private void taoDuLieuMau() {
        tatCaSap.clear();
        tatCaSap.add(new SapHang("RC-01", "Rau củ", "Cô Tư Rau", 1));
        tatCaSap.add(new SapHang("RC-02", "Rau củ", "Chị Lan Củ", 1));
        tatCaSap.add(new SapHang("RC-03", "Rau củ", "Trống", 0));
        tatCaSap.add(new SapHang("TC-01", "Thịt cá", "Anh Ba Thịt", 1));
        tatCaSap.add(new SapHang("TC-02", "Thịt cá", "Chú Sáu Cá", -1));
        tatCaSap.add(new SapHang("TC-03", "Thịt cá", "Trống", 0));
        tatCaSap.add(new SapHang("DK-01", "Đồ khô", "Bà Năm Mắm", 1));
        tatCaSap.add(new SapHang("DK-02", "Đồ khô", "Trống", 0));
        tatCaSap.add(new SapHang("GD-01", "Đồ gia dụng", "Chú Tám Nhựa", 1));
        tatCaSap.add(new SapHang("GD-02", "Đồ gia dụng", "Cô Hoa Nồi", 1));
        tatCaSap.add(new SapHang("GD-03", "Đồ gia dụng", "Trống", 0));
    }
}