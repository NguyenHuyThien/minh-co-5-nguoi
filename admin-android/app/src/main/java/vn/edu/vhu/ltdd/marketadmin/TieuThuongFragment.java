package vn.edu.vhu.ltdd.marketadmin;

import android.app.AlertDialog;
import android.content.Context;
import android.graphics.Color;
import android.os.Bundle;
import android.text.Editable;
import android.text.InputType;
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
import android.widget.RadioButton;
import android.widget.RadioGroup;
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

public class TieuThuongFragment extends Fragment {

    private RecyclerView rvTieuThuong;
    private TieuThuongAdapter adapter;
    private final List<TieuThuong> tatCaTieuThuong = new ArrayList<>();

    private CardView cardStatHoatDong, cardStatTamNgung, cardStatKhoa;
    private TextView tvStatHoatDong, tvStatTamNgung, tvStatKhoa, tvKhongCoKetQua;
    private Integer trangThaiLoc = null;

    private String khuVucHienTai = "Tất cả";
    private String tuKhoaHienTai = "";

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_tieu_thuong, container, false);

        rvTieuThuong = view.findViewById(R.id.rvTieuThuong);
        ChipGroup chipGroup = view.findViewById(R.id.chipGroupKhuVucTT);
        EditText etTimKiem = view.findViewById(R.id.etTimKiemTT);
        ImageView btnXoaTimKiem = view.findViewById(R.id.btnXoaTimKiemTT);
        FloatingActionButton fabThem = view.findViewById(R.id.fabThemTieuThuong);

        cardStatHoatDong = view.findViewById(R.id.cardStatTTHoatDong);
        cardStatTamNgung = view.findViewById(R.id.cardStatTTTamNgung);
        cardStatKhoa = view.findViewById(R.id.cardStatTTKhoa);
        tvStatHoatDong = view.findViewById(R.id.tvStatTTHoatDong);
        tvStatTamNgung = view.findViewById(R.id.tvStatTTTamNgung);
        tvStatKhoa = view.findViewById(R.id.tvStatTTKhoa);
        tvKhongCoKetQua = view.findViewById(R.id.tvKhongCoKetQuaTT);

        taoDuLieuMau();

        rvTieuThuong.setLayoutManager(new LinearLayoutManager(getContext()));
        adapter = new TieuThuongAdapter(tatCaTieuThuong, this::hienDialogChiTietTT);
        rvTieuThuong.setAdapter(adapter);

        cardStatHoatDong.setOnClickListener(v -> chonBoLocTrangThai(1));
        cardStatTamNgung.setOnClickListener(v -> chonBoLocTrangThai(0));
        cardStatKhoa.setOnClickListener(v -> chonBoLocTrangThai(-1));

        chipGroup.setOnCheckedStateChangeListener((group, checkedIds) -> {
            if (checkedIds.isEmpty()) return;
            int id = checkedIds.get(0);

            if (id == R.id.chipTatCaTT) khuVucHienTai = "Tất cả";
            else if (id == R.id.chipRauCuTT) khuVucHienTai = "Rau củ";
            else if (id == R.id.chipThitCaTT) khuVucHienTai = "Thịt cá";
            else if (id == R.id.chipDoKhoTT) khuVucHienTai = "Đồ khô";
            else if (id == R.id.chipGiaDungTT) khuVucHienTai = "Đồ gia dụng";

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

        fabThem.setOnClickListener(v -> hienDialogThemTieuThuong());

        locDanhSach();
        return view;
    }

    private void hienDialogThemTieuThuong() {
        if (getContext() == null) return;

        List<SapHang> tatCaSapTrong = MarketRepository.layTatCaSapTrong();
        if (tatCaSapTrong.isEmpty()) {
            new AlertDialog.Builder(getContext())
                    .setTitle("Không thể thêm tiểu thương")
                    .setMessage("Chợ đã hết vị trí trống. Vui lòng tạo thêm sạp trống ở Sơ đồ chợ trước khi đăng ký tiểu thương mới.")
                    .setPositiveButton("Đã hiểu", null)
                    .show();
            return;
        }

        LinearLayout layout = new LinearLayout(getContext());
        layout.setOrientation(LinearLayout.VERTICAL);
        int pad = (int) (20 * getResources().getDisplayMetrics().density);
        layout.setPadding(pad, pad / 2, pad, 0);

        EditText etHoTen = new EditText(getContext());
        etHoTen.setHint("Họ tên tiểu thương");
        etHoTen.setSingleLine(true);
        layout.addView(etHoTen);

        EditText etSdt = new EditText(getContext());
        etSdt.setHint("Số điện thoại (VD: 0909123456)");
        etSdt.setInputType(InputType.TYPE_CLASS_PHONE);
        etSdt.setSingleLine(true);
        layout.addView(etSdt);

        TextView tvChonSap = new TextView(getContext());
        tvChonSap.setText("Chọn vị trí sạp đang trống (" + tatCaSapTrong.size() + " sạp):");
        tvChonSap.setTextColor(Color.parseColor("#0F766E"));
        tvChonSap.setPadding(0, pad / 2, 0, 6);
        layout.addView(tvChonSap);

        List<String> dsHienThiSap = new ArrayList<>();
        for (SapHang sap : tatCaSapTrong) {
            dsHienThiSap.add("Sạp " + sap.maSap + " - Khu " + sap.khuVuc);
        }

        Spinner spSapTrong = new Spinner(getContext());
        ArrayAdapter<String> sapAdapter = new ArrayAdapter<>(getContext(), android.R.layout.simple_spinner_dropdown_item, dsHienThiSap);
        spSapTrong.setAdapter(sapAdapter);
        layout.addView(spSapTrong);

        AlertDialog dialog = new AlertDialog.Builder(getContext())
                .setTitle("Thêm tiểu thương mới")
                .setView(layout)
                .setPositiveButton("Đăng ký", null)
                .setNegativeButton("Hủy", null)
                .create();

        dialog.setOnShowListener(d -> dialog.getButton(AlertDialog.BUTTON_POSITIVE).setOnClickListener(v -> {
            String hoTen = etHoTen.getText().toString().trim();
            String sdt = etSdt.getText().toString().trim();

            if (hoTen.isEmpty()) {
                etHoTen.setError("Vui lòng nhập họ tên");
                return;
            }
            if (sdt.isEmpty()) {
                etSdt.setError("Vui lòng nhập số điện thoại");
                return;
            }

            int viTriChon = spSapTrong.getSelectedItemPosition();
            SapHang sapDuocChon = tatCaSapTrong.get(viTriChon);

            String maTT = String.format("TT-%02d", MarketRepository.dsTieuThuong.size() + 1);
            MarketRepository.dsTieuThuong.add(0, new TieuThuong(maTT, hoTen, sdt, sapDuocChon.maSap, sapDuocChon.khuVuc, 1, ""));
            MarketRepository.ganTieuThuongVaoSap(sapDuocChon.maSap, hoTen);

            locDanhSach();
            rvTieuThuong.scrollToPosition(0);
            Toast.makeText(getContext(), "Đã đăng ký " + hoTen + " vào sạp " + sapDuocChon.maSap, Toast.LENGTH_SHORT).show();
            dialog.dismiss();
        }));

        dialog.show();
    }

    private void hienDialogChiTietTT(TieuThuong tt) {
        if (getContext() == null) return;

        LinearLayout layout = new LinearLayout(getContext());
        layout.setOrientation(LinearLayout.VERTICAL);
        int pad = (int) (20 * getResources().getDisplayMetrics().density);
        layout.setPadding(pad, pad / 2, pad, 0);

        EditText etHoTen = new EditText(getContext());
        etHoTen.setText(tt.hoTen);
        etHoTen.setHint("Họ tên tiểu thương");
        layout.addView(etHoTen);

        EditText etSdt = new EditText(getContext());
        etSdt.setText(tt.soDienThoai);
        etSdt.setInputType(InputType.TYPE_CLASS_PHONE);
        etSdt.setHint("Số điện thoại");
        layout.addView(etSdt);

        EditText etMaSap = new EditText(getContext());
        etMaSap.setText(tt.maSap);
        etMaSap.setHint("Mã sạp");
        layout.addView(etMaSap);

        TextView tvLabelTrangThai = new TextView(getContext());
        tvLabelTrangThai.setText("Trạng thái hoạt động:");
        tvLabelTrangThai.setTextColor(Color.parseColor("#334155"));
        tvLabelTrangThai.setPadding(0, pad / 2, 0, 4);
        layout.addView(tvLabelTrangThai);

        RadioGroup rgTrangThai = new RadioGroup(getContext());
        rgTrangThai.setOrientation(RadioGroup.VERTICAL);

        RadioButton rbHoatDong = new RadioButton(getContext());
        rbHoatDong.setText("Hoạt động");
        rgTrangThai.addView(rbHoatDong);

        RadioButton rbTamNgung = new RadioButton(getContext());
        rbTamNgung.setText("Tạm ngưng");
        rgTrangThai.addView(rbTamNgung);

        RadioButton rbKhoa = new RadioButton(getContext());
        rbKhoa.setText("Khóa tài khoản");
        rgTrangThai.addView(rbKhoa);

        layout.addView(rgTrangThai);

        EditText etLyDo = new EditText(getContext());
        etLyDo.setHint("Nhập lý do tạm ngưng / khóa...");
        etLyDo.setText(tt.lyDo != null ? tt.lyDo : "");
        layout.addView(etLyDo);

        if (tt.trangThai == 1) {
            rbHoatDong.setChecked(true);
            etLyDo.setVisibility(View.GONE);
        } else if (tt.trangThai == 0) {
            rbTamNgung.setChecked(true);
            etLyDo.setVisibility(View.VISIBLE);
        } else {
            rbKhoa.setChecked(true);
            etLyDo.setVisibility(View.VISIBLE);
        }

        rgTrangThai.setOnCheckedChangeListener((group, checkedId) -> {
            if (checkedId == rbHoatDong.getId()) {
                etLyDo.setVisibility(View.GONE);
            } else {
                etLyDo.setVisibility(View.VISIBLE);
                etLyDo.requestFocus();
            }
        });

        AlertDialog dialog = new AlertDialog.Builder(getContext())
                .setTitle("Tiểu thương " + tt.maTT + " • " + tt.khuVuc)
                .setView(layout)
                .setPositiveButton("Cập nhật", null)
                .setNeutralButton("Xóa", (d, which) -> xacNhanXoaTT(tt))
                .setNegativeButton("Đóng", null)
                .create();

        dialog.setOnShowListener(d -> {
            dialog.getButton(AlertDialog.BUTTON_NEUTRAL).setTextColor(Color.parseColor("#DC2626"));
            dialog.getButton(AlertDialog.BUTTON_POSITIVE).setOnClickListener(v -> {
                String hoTenMoi = etHoTen.getText().toString().trim();
                String sdtMoi = etSdt.getText().toString().trim();
                String maSapMoi = etMaSap.getText().toString().trim().toUpperCase();
                String lyDoMoi = etLyDo.getText().toString().trim();

                if (hoTenMoi.isEmpty() || sdtMoi.isEmpty() || maSapMoi.isEmpty()) {
                    Toast.makeText(getContext(), "Vui lòng nhập đầy đủ thông tin", Toast.LENGTH_SHORT).show();
                    return;
                }

                if (!rbHoatDong.isChecked() && lyDoMoi.isEmpty()) {
                    etLyDo.setError("Vui lòng nhập lý do");
                    return;
                }

                tt.hoTen = hoTenMoi;
                tt.soDienThoai = sdtMoi;
                tt.maSap = maSapMoi;

                if (rbHoatDong.isChecked()) {
                    tt.trangThai = 1;
                    tt.lyDo = "";
                } else if (rbTamNgung.isChecked()) {
                    tt.trangThai = 0;
                    tt.lyDo = lyDoMoi;
                } else {
                    tt.trangThai = -1;
                    tt.lyDo = lyDoMoi;
                }

                locDanhSach();
                Toast.makeText(getContext(), "Đã cập nhật tiểu thương " + tt.hoTen, Toast.LENGTH_SHORT).show();
                dialog.dismiss();
            });
        });

        dialog.show();
    }

    private void xacNhanXoaTT(TieuThuong tt) {
        if (getContext() == null) return;

        new AlertDialog.Builder(getContext())
                .setTitle("Xác nhận xóa")
                .setMessage("Xóa tiểu thương " + tt.hoTen + " (Sạp " + tt.maSap + ") khỏi danh sách?")
                .setPositiveButton("Xóa", (dialog, which) -> {
                    tatCaTieuThuong.remove(tt);
                    locDanhSach();
                    Toast.makeText(getContext(), "Đã xóa tiểu thương " + tt.hoTen, Toast.LENGTH_SHORT).show();
                })
                .setNegativeButton("Hủy", null)
                .show();
    }

    private void chonBoLocTrangThai(int trangThai) {
        if (trangThaiLoc != null && trangThaiLoc == trangThai) {
            trangThaiLoc = null;
        } else {
            trangThaiLoc = trangThai;
        }
        cardStatHoatDong.setCardElevation(trangThaiLoc != null && trangThaiLoc == 1 ? 8f : 0f);
        cardStatTamNgung.setCardElevation(trangThaiLoc != null && trangThaiLoc == 0 ? 8f : 0f);
        cardStatKhoa.setCardElevation(trangThaiLoc != null && trangThaiLoc == -1 ? 8f : 0f);

        cardStatHoatDong.setAlpha(trangThaiLoc == null || trangThaiLoc == 1 ? 1.0f : 0.45f);
        cardStatTamNgung.setAlpha(trangThaiLoc == null || trangThaiLoc == 0 ? 1.0f : 0.45f);
        cardStatKhoa.setAlpha(trangThaiLoc == null || trangThaiLoc == -1 ? 1.0f : 0.45f);
        locDanhSach();
    }

    private void locDanhSach() {
        List<TieuThuong> ketQua = new ArrayList<>();
        int demHoatDong = 0, demTamNgung = 0, demKhoa = 0;

        for (TieuThuong tt : tatCaTieuThuong) {
            boolean khopKhuVuc = khuVucHienTai.equals("Tất cả") || tt.khuVuc.equals(khuVucHienTai);
            boolean khopTuKhoa = tuKhoaHienTai.isEmpty()
                    || boDauTiengViet(tt.maTT).contains(tuKhoaHienTai)
                    || boDauTiengViet(tt.hoTen).contains(tuKhoaHienTai)
                    || tt.soDienThoai.contains(tuKhoaHienTai)
                    || boDauTiengViet(tt.maSap).contains(tuKhoaHienTai);

            if (khopKhuVuc && khopTuKhoa) {
                if (tt.trangThai == 1) demHoatDong++;
                else if (tt.trangThai == 0) demTamNgung++;
                else demKhoa++;

                if (trangThaiLoc == null || tt.trangThai == trangThaiLoc) {
                    ketQua.add(tt);
                }
            }
        }

        tvStatHoatDong.setText(demHoatDong + " người");
        tvStatTamNgung.setText(demTamNgung + " người");
        tvStatKhoa.setText(demKhoa + " người");

        tvKhongCoKetQua.setVisibility(ketQua.isEmpty() ? View.VISIBLE : View.GONE);
        rvTieuThuong.setVisibility(ketQua.isEmpty() ? View.GONE : View.VISIBLE);

        adapter.updateData(ketQua);
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

    private void taoDuLieuMau() {
        tatCaTieuThuong.clear();
        tatCaTieuThuong.add(new TieuThuong("TT-01", "Cô Tư Rau", "0901234501", "RC-01", "Rau củ", 1, ""));
        tatCaTieuThuong.add(new TieuThuong("TT-02", "Chị Lan Củ", "0901234502", "RC-02", "Rau củ", 1, ""));
        tatCaTieuThuong.add(new TieuThuong("TT-03", "Anh Ba Thịt", "0901234503", "TC-01", "Thịt cá", 1, ""));
        tatCaTieuThuong.add(new TieuThuong("TT-04", "Chú Sáu Cá", "0901234504", "TC-02", "Thịt cá", 0, "Xin nghỉ phép 1 tuần vì việc gia đình"));
        tatCaTieuThuong.add(new TieuThuong("TT-05", "Bà Năm Mắm", "0901234505", "DK-01", "Đồ khô", -1, "Vi phạm quy định vệ sinh an toàn thực phẩm"));
        tatCaTieuThuong.add(new TieuThuong("TT-06", "Chú Tám Nhựa", "0901234506", "GD-01", "Đồ gia dụng", 1, ""));
        tatCaTieuThuong.add(new TieuThuong("TT-07", "Cô Hoa Nồi", "0901234507", "GD-02", "Đồ gia dụng", 1, ""));
    }
}