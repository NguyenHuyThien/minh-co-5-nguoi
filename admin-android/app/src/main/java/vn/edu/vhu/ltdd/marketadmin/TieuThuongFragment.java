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
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RadioButton;
import android.widget.RadioGroup;
import android.widget.TextView;
import android.widget.Toast;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.cardview.widget.CardView;
import androidx.fragment.app.Fragment;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import com.google.android.material.chip.ChipGroup;
import java.text.Normalizer;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Locale;
import java.util.regex.Pattern;

public class TieuThuongFragment extends Fragment {

    private RecyclerView rvTieuThuong;
    private TieuThuongAdapter adapter;

    private CardView cardStatHoatDong, cardStatTamNgung, cardStatDaKhoa;
    private TextView tvStatHoatDong, tvStatTamNgung, tvStatDaKhoa, tvKhongCoKetQuaTT;
    private Integer trangThaiLoc = null;

    private String khuVucHienTai = "Tất cả";
    private String tuKhoaHienTai = "";

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_tieu_thuong, container, false);

        MarketRepository.khoiTaoDuLieu();

        rvTieuThuong = view.findViewById(R.id.rvTieuThuong);
        ChipGroup chipGroup = view.findViewById(R.id.chipGroupKhuVucTT);
        EditText etTimKiem = view.findViewById(R.id.etTimKiemTieuThuong);
        ImageView btnXoaTimKiem = view.findViewById(R.id.btnXoaTimKiemTT);

        cardStatHoatDong = view.findViewById(R.id.cardStatHoatDong);
        cardStatTamNgung = view.findViewById(R.id.cardStatTamNgung);
        cardStatDaKhoa = view.findViewById(R.id.cardStatDaKhoa);
        tvStatHoatDong = view.findViewById(R.id.tvStatHoatDong);
        tvStatTamNgung = view.findViewById(R.id.tvStatTamNgung);
        tvStatDaKhoa = view.findViewById(R.id.tvStatDaKhoa);
        tvKhongCoKetQuaTT = view.findViewById(R.id.tvKhongCoKetQuaTT);

        rvTieuThuong.setLayoutManager(new LinearLayoutManager(getContext()));
        adapter = new TieuThuongAdapter(MarketRepository.dsTieuThuong, this::hienDialogChiTietTieuThuong);
        rvTieuThuong.setAdapter(adapter);

        cardStatHoatDong.setOnClickListener(v -> chonBoLocTrangThai(1));
        cardStatTamNgung.setOnClickListener(v -> chonBoLocTrangThai(0));
        cardStatDaKhoa.setOnClickListener(v -> chonBoLocTrangThai(-1));

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

        locDanhSach();
        return view;
    }

    @Override
    public void onResume() {
        super.onResume();
        locDanhSach();
    }

    private void hienDialogChiTietTieuThuong(TieuThuong tt) {
        if (getContext() == null) return;

        LinearLayout layout = new LinearLayout(getContext());
        layout.setOrientation(LinearLayout.VERTICAL);
        int pad = (int) (20 * getResources().getDisplayMetrics().density);
        layout.setPadding(pad, pad / 2, pad, 0);

        TextView tvViTri = new TextView(getContext());
        tvViTri.setText("Mã: " + tt.maTT + "  •  Vị trí: Sạp " + tt.maSap + " (" + tt.khuVuc + ")");
        tvViTri.setTextColor(Color.parseColor("#0F766E"));
        tvViTri.setTextSize(13f);
        tvViTri.setPadding(0, 0, 0, 12);
        layout.addView(tvViTri);

        EditText etHoTen = new EditText(getContext());
        etHoTen.setText(tt.hoTen);
        etHoTen.setHint("Họ tên tiểu thương");
        etHoTen.setSingleLine(true);
        layout.addView(etHoTen);

        EditText etSdt = new EditText(getContext());
        etSdt.setText(tt.soDienThoai);
        etSdt.setHint("Số điện thoại");
        etSdt.setInputType(InputType.TYPE_CLASS_PHONE);
        etSdt.setSingleLine(true);
        layout.addView(etSdt);

        TextView tvLabelTrangThai = new TextView(getContext());
        tvLabelTrangThai.setText("Trạng thái gian hàng:");
        tvLabelTrangThai.setTextColor(Color.parseColor("#334155"));
        tvLabelTrangThai.setPadding(0, 14, 0, 4);
        layout.addView(tvLabelTrangThai);

        RadioGroup radioGroup = new RadioGroup(getContext());
        RadioButton rbHoatDong = new RadioButton(getContext());
        rbHoatDong.setText("Mở / Đang hoạt động");
        RadioButton rbTamNgung = new RadioButton(getContext());
        rbTamNgung.setText("Tạm ngưng kinh doanh");
        RadioButton rbKhoa = new RadioButton(getContext());
        rbKhoa.setText("Khóa gian hàng");

        radioGroup.addView(rbHoatDong);
        radioGroup.addView(rbTamNgung);
        radioGroup.addView(rbKhoa);
        layout.addView(radioGroup);

        EditText etLyDo = new EditText(getContext());
        etLyDo.setHint("Nhập lý do khóa / tạm ngưng...");
        etLyDo.setText(tt.lyDo != null ? tt.lyDo : "");
        etLyDo.setSingleLine(true);
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

        radioGroup.setOnCheckedChangeListener((group, checkedId) -> {
            if (checkedId == rbHoatDong.getId()) {
                etLyDo.setVisibility(View.GONE);
                etLyDo.setError(null);
            } else {
                etLyDo.setVisibility(View.VISIBLE);
            }
        });

        AlertDialog dialog = new AlertDialog.Builder(getContext())
                .setTitle(tt.hoTen + " (" + tt.maSap + ")")
                .setView(layout)
                .setPositiveButton("Lưu cập nhật", null)
                .setNeutralButton("Lịch sử vi phạm (" + tt.lichSuViPham.size() + ")", (d, which) -> hienDialogLichSuViPham(tt))
                .setNegativeButton("Thu hồi sạp", (d, which) -> xacNhanThuHoiSap(tt))
                .create();

        dialog.setOnShowListener(d -> {
            dialog.getButton(AlertDialog.BUTTON_NEGATIVE).setTextColor(Color.parseColor("#DC2626"));
            dialog.getButton(AlertDialog.BUTTON_NEUTRAL).setTextColor(Color.parseColor("#B45309"));
            dialog.getButton(AlertDialog.BUTTON_POSITIVE).setOnClickListener(v -> {
                String hoTenMoi = etHoTen.getText().toString().trim();
                String sdtMoi = etSdt.getText().toString().trim();
                String lyDoMoi = etLyDo.getText().toString().trim();

                if (hoTenMoi.isEmpty()) {
                    etHoTen.setError("Vui lòng nhập họ tên");
                    return;
                }
                if (sdtMoi.isEmpty()) {
                    etSdt.setError("Vui lòng nhập số điện thoại");
                    return;
                }

                int trangThaiMoi;
                if (rbHoatDong.isChecked()) {
                    trangThaiMoi = 1;
                    lyDoMoi = "";
                } else if (rbTamNgung.isChecked()) {
                    trangThaiMoi = 0;
                    if (lyDoMoi.isEmpty()) {
                        etLyDo.setError("Vui lòng nhập lý do tạm ngưng");
                        return;
                    }
                } else {
                    trangThaiMoi = -1;
                    if (lyDoMoi.isEmpty()) {
                        etLyDo.setError("Vui lòng nhập lý do khóa gian hàng");
                        return;
                    }
                    if (tt.trangThai != -1) {
                        String ngayHomNay = new SimpleDateFormat("dd/MM/yyyy", Locale.getDefault()).format(new Date());
                        tt.lichSuViPham.add(ngayHomNay + " - " + lyDoMoi + " - Khóa gian hàng");
                    }
                }

                tt.hoTen = hoTenMoi;
                tt.soDienThoai = sdtMoi;
                tt.trangThai = trangThaiMoi;
                tt.lyDo = lyDoMoi;
                MarketRepository.ganTieuThuongVaoSap(tt.maSap, hoTenMoi);

                locDanhSach();
                Toast.makeText(getContext(), "Đã cập nhật gian hàng " + tt.hoTen, Toast.LENGTH_SHORT).show();
                dialog.dismiss();
            });
        });

        dialog.show();
    }

    private void hienDialogLichSuViPham(TieuThuong tt) {
        if (getContext() == null) return;

        StringBuilder noiDung = new StringBuilder();
        if (tt.lichSuViPham.isEmpty()) {
            noiDung.append("Tiểu thương chưa có ghi nhận vi phạm nào.");
        } else {
            for (int i = 0; i < tt.lichSuViPham.size(); i++) {
                noiDung.append(i + 1).append(". ").append(tt.lichSuViPham.get(i)).append("\n\n");
            }
        }

        new AlertDialog.Builder(getContext())
                .setTitle("Lịch sử vi phạm • " + tt.hoTen)
                .setMessage(noiDung.toString().trim())
                .setPositiveButton("Ghi nhận vi phạm", (d, which) -> hienDialogThemViPham(tt))
                .setNegativeButton("Đóng", null)
                .show();
    }

    private void hienDialogThemViPham(TieuThuong tt) {
        if (getContext() == null) return;

        LinearLayout layout = new LinearLayout(getContext());
        layout.setOrientation(LinearLayout.VERTICAL);
        int pad = (int) (20 * getResources().getDisplayMetrics().density);
        layout.setPadding(pad, pad / 2, pad, 0);

        EditText etNoiDungViPham = new EditText(getContext());
        etNoiDungViPham.setHint("Nội dung vi phạm (VD: Lấn chiếm lối đi...)");
        etNoiDungViPham.setSingleLine(true);
        layout.addView(etNoiDungViPham);

        EditText etHinhThucXuLy = new EditText(getContext());
        etHinhThucXuLy.setHint("Hình thức xử lý (VD: Nhắc nhở, Cảnh cáo...)");
        etHinhThucXuLy.setSingleLine(true);
        layout.addView(etHinhThucXuLy);

        AlertDialog dialog = new AlertDialog.Builder(getContext())
                .setTitle("Lập biên bản vi phạm • " + tt.maSap)
                .setView(layout)
                .setPositiveButton("Lưu biên bản", null)
                .setNegativeButton("Hủy", null)
                .create();

        dialog.setOnShowListener(d -> dialog.getButton(AlertDialog.BUTTON_POSITIVE).setOnClickListener(v -> {
            String noiDung = etNoiDungViPham.getText().toString().trim();
            String xuLy = etHinhThucXuLy.getText().toString().trim();

            if (noiDung.isEmpty()) {
                etNoiDungViPham.setError("Vui lòng nhập nội dung vi phạm");
                return;
            }
            if (xuLy.isEmpty()) {
                xuLy = "Nhắc nhở";
            }

            String ngayHomNay = new SimpleDateFormat("dd/MM/yyyy", Locale.getDefault()).format(new Date());
            tt.lichSuViPham.add(ngayHomNay + " - " + noiDung + " - " + xuLy);
            Toast.makeText(getContext(), "Đã ghi nhận vi phạm cho " + tt.hoTen, Toast.LENGTH_SHORT).show();
            dialog.dismiss();
            hienDialogLichSuViPham(tt);
        }));

        dialog.show();
    }

    private void xacNhanThuHoiSap(TieuThuong tt) {
        if (getContext() == null) return;

        new AlertDialog.Builder(getContext())
                .setTitle("Thu hồi gian hàng")
                .setMessage("Chấm dứt hợp đồng của " + tt.hoTen + " và trả sạp " + tt.maSap + " về trạng thái Sạp trống?")
                .setPositiveButton("Thu hồi", (dialog, which) -> {
                    MarketRepository.dsTieuThuong.remove(tt);
                    MarketRepository.traLaiSapTrong(tt.maSap);
                    locDanhSach();
                    Toast.makeText(getContext(), "Đã thu hồi và trả trống sạp " + tt.maSap, Toast.LENGTH_SHORT).show();
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
        cardStatDaKhoa.setCardElevation(trangThaiLoc != null && trangThaiLoc == -1 ? 8f : 0f);

        cardStatHoatDong.setAlpha(trangThaiLoc == null || trangThaiLoc == 1 ? 1.0f : 0.45f);
        cardStatTamNgung.setAlpha(trangThaiLoc == null || trangThaiLoc == 0 ? 1.0f : 0.45f);
        cardStatDaKhoa.setAlpha(trangThaiLoc == null || trangThaiLoc == -1 ? 1.0f : 0.45f);
        locDanhSach();
    }

    private void locDanhSach() {
        List<TieuThuong> ketQua = new ArrayList<>();
        int demHoatDong = 0, demTamNgung = 0, demDaKhoa = 0;

        for (TieuThuong tt : MarketRepository.dsTieuThuong) {
            boolean khopKhuVuc = khuVucHienTai.equals("Tất cả") || tt.khuVuc.equals(khuVucHienTai);
            boolean khopTuKhoa = tuKhoaHienTai.isEmpty()
                    || boDauTiengViet(tt.hoTen).contains(tuKhoaHienTai)
                    || boDauTiengViet(tt.maSap).contains(tuKhoaHienTai)
                    || tt.soDienThoai.contains(tuKhoaHienTai);

            if (khopKhuVuc && khopTuKhoa) {
                if (tt.trangThai == 1) demHoatDong++;
                else if (tt.trangThai == 0) demTamNgung++;
                else demDaKhoa++;

                if (trangThaiLoc == null || tt.trangThai == trangThaiLoc) {
                    ketQua.add(tt);
                }
            }
        }

        tvStatHoatDong.setText(demHoatDong + " người");
        tvStatTamNgung.setText(demTamNgung + " người");
        tvStatDaKhoa.setText(demDaKhoa + " người");

        tvKhongCoKetQuaTT.setVisibility(ketQua.isEmpty() ? View.VISIBLE : View.GONE);
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
}