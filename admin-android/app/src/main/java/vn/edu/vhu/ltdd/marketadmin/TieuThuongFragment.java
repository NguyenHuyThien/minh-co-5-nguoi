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

        List<SapHang> dsSapSoHuu = MarketRepository.laySapCuaTieuThuong(tt.maTT);

        LinearLayout layout = new LinearLayout(getContext());
        layout.setOrientation(LinearLayout.VERTICAL);
        int pad = (int) (20 * getResources().getDisplayMetrics().density);
        layout.setPadding(pad, pad / 2, pad, 0);

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

        TextView tvDanhSachGian = new TextView(getContext());
        tvDanhSachGian.setText("Danh sách gian hàng đang sở hữu (" + dsSapSoHuu.size() + "):");
        tvDanhSachGian.setTextColor(Color.parseColor("#0F766E"));
        tvDanhSachGian.setPadding(0, 16, 0, 8);
        layout.addView(tvDanhSachGian);

        if (dsSapSoHuu.isEmpty()) {
            TextView tvTrong = new TextView(getContext());
            tvTrong.setText("Chưa có gian hàng nào được duyệt.");
            tvTrong.setTextColor(Color.parseColor("#64748B"));
            layout.addView(tvTrong);
        } else {
            for (SapHang sap : dsSapSoHuu) {
                TextView tvItemSap = new TextView(getContext());
                String trangThaiText = (sap.trangThai == -2) ? " [ĐÃ KHÓA: " + sap.lyDo + "]" : " [Đang hoạt động]";
                tvItemSap.setText("• Sạp " + sap.maSap + " (" + sap.khuVuc + ") - " + sap.tenGianHang + trangThaiText + "\n   (Bấm vào dòng này để Khóa/Mở khóa gian hàng)");
                tvItemSap.setTextColor(sap.trangThai == -2 ? Color.parseColor("#B91C1C") : Color.parseColor("#1E293B"));
                tvItemSap.setPadding(0, 8, 0, 8);
                tvItemSap.setOnClickListener(v -> hienDialogQuanLyMotGianHang(tt, sap));
                layout.addView(tvItemSap);
            }
        }

        AlertDialog dialog = new AlertDialog.Builder(getContext())
                .setTitle("Hồ sơ tiểu thương • " + tt.maTT)
                .setView(layout)
                .setPositiveButton("Lưu thông tin", null)
                .setNeutralButton("Lịch sử vi phạm (" + tt.lichSuViPham.size() + ")", (d, which) -> hienDialogLichSuViPham(tt))
                .setNegativeButton("Đóng", null)
                .create();

        dialog.setOnShowListener(d -> {
            dialog.getButton(AlertDialog.BUTTON_NEUTRAL).setTextColor(Color.parseColor("#B45309"));
            dialog.getButton(AlertDialog.BUTTON_POSITIVE).setOnClickListener(v -> {
                String hoTenMoi = etHoTen.getText().toString().trim();
                String sdtMoi = etSdt.getText().toString().trim();

                if (hoTenMoi.isEmpty()) {
                    etHoTen.setError("Vui lòng nhập họ tên");
                    return;
                }
                if (sdtMoi.isEmpty()) {
                    etSdt.setError("Vui lòng nhập số điện thoại");
                    return;
                }

                tt.hoTen = hoTenMoi;
                tt.soDienThoai = sdtMoi;
                for (SapHang s : MarketRepository.dsSap) {
                    if (s.maTT != null && s.maTT.equalsIgnoreCase(tt.maTT)) {
                        s.tenTieuThuong = hoTenMoi;
                        s.soDienThoai = sdtMoi;
                    }
                }

                locDanhSach();
                Toast.makeText(getContext(), "Đã cập nhật thông tin " + tt.hoTen, Toast.LENGTH_SHORT).show();
                dialog.dismiss();
            });
        });

        dialog.show();
    }

    private void hienDialogQuanLyMotGianHang(TieuThuong tt, SapHang sap) {
        if (getContext() == null) return;

        if (sap.trangThai == -2) {
            new AlertDialog.Builder(getContext())
                    .setTitle("Mở khóa gian hàng " + sap.maSap)
                    .setMessage("Gian hàng \"" + sap.tenGianHang + "\" đang bị khóa với lý do:\n" + sap.lyDo + "\n\nXác nhận mở khóa hoạt động lại?")
                    .setPositiveButton("Mở khóa", (d, which) -> {
                        MarketRepository.moKhoaSap(sap);
                        locDanhSach();
                        Toast.makeText(getContext(), "Đã mở khóa gian hàng " + sap.maSap, Toast.LENGTH_SHORT).show();
                    })
                    .setNeutralButton("Thu hồi sạp", (d, which) -> xacNhanThuHoiSap(sap))
                    .setNegativeButton("Hủy", null)
                    .show();
        } else {
            LinearLayout layout = new LinearLayout(getContext());
            layout.setOrientation(LinearLayout.VERTICAL);
            int pad = (int) (20 * getResources().getDisplayMetrics().density);
            layout.setPadding(pad, pad / 2, pad, 0);

            EditText etLyDo = new EditText(getContext());
            etLyDo.setHint("Nhập lý do khóa gian hàng...");
            etLyDo.setSingleLine(true);
            layout.addView(etLyDo);

            AlertDialog dialog = new AlertDialog.Builder(getContext())
                    .setTitle("Khóa gian hàng " + sap.maSap)
                    .setView(layout)
                    .setPositiveButton("Khóa gian hàng", null)
                    .setNeutralButton("Thu hồi sạp", (d, which) -> xacNhanThuHoiSap(sap))
                    .setNegativeButton("Hủy", null)
                    .create();

            dialog.setOnShowListener(d -> {
                dialog.getButton(AlertDialog.BUTTON_NEUTRAL).setTextColor(Color.parseColor("#DC2626"));
                dialog.getButton(AlertDialog.BUTTON_POSITIVE).setOnClickListener(v -> {
                    String lyDo = etLyDo.getText().toString().trim();
                    if (lyDo.isEmpty()) {
                        etLyDo.setError("Vui lòng nhập lý do khóa");
                        return;
                    }
                    MarketRepository.khoaSap(sap, lyDo);
                    String ngayHomNay = new SimpleDateFormat("dd/MM/yyyy", Locale.getDefault()).format(new Date());
                    tt.lichSuViPham.add(ngayHomNay + " - [Sạp " + sap.maSap + "] " + lyDo + " - Khóa gian hàng");
                    locDanhSach();
                    Toast.makeText(getContext(), "Đã khóa gian hàng " + sap.maSap, Toast.LENGTH_SHORT).show();
                    dialog.dismiss();
                });
            });
            dialog.show();
        }
    }

    private void xacNhanThuHoiSap(SapHang sap) {
        if (getContext() == null) return;

        new AlertDialog.Builder(getContext())
                .setTitle("Thu hồi sạp " + sap.maSap)
                .setMessage("Chấm dứt hoạt động của gian hàng \"" + sap.tenGianHang + "\" và trả Sạp " + sap.maSap + " về trạng thái Sạp trống?")
                .setPositiveButton("Thu hồi", (dialog, which) -> {
                    MarketRepository.traSapVeTrong(sap);
                    locDanhSach();
                    Toast.makeText(getContext(), "Đã thu hồi và trả trống Sạp " + sap.maSap, Toast.LENGTH_SHORT).show();
                })
                .setNegativeButton("Hủy", null)
                .show();
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
                .setTitle("Lập biên bản vi phạm • " + tt.maTT)
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
            locDanhSach();
            Toast.makeText(getContext(), "Đã ghi nhận vi phạm cho " + tt.hoTen, Toast.LENGTH_SHORT).show();
            dialog.dismiss();
            hienDialogLichSuViPham(tt);
        }));

        dialog.show();
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
        int demHoatDong = 0, demChuaCoSap = 0, demCoGianKhoa = 0;

        for (TieuThuong tt : MarketRepository.dsTieuThuong) {
            List<SapHang> dsSapSoHuu = MarketRepository.laySapCuaTieuThuong(tt.maTT);

            boolean khopKhuVuc = khuVucHienTai.equals("Tất cả");
            StringBuilder chuoiMaSap = new StringBuilder();
            int soGianKhoa = 0;

            for (SapHang s : dsSapSoHuu) {
                if (s.khuVuc.equals(khuVucHienTai)) khopKhuVuc = true;
                chuoiMaSap.append(s.maSap).append(" ");
                if (s.trangThai == -2) soGianKhoa++;
            }

            boolean khopTuKhoa = tuKhoaHienTai.isEmpty()
                    || boDauTiengViet(tt.hoTen).contains(tuKhoaHienTai)
                    || boDauTiengViet(tt.maTT).contains(tuKhoaHienTai)
                    || boDauTiengViet(chuoiMaSap.toString()).contains(tuKhoaHienTai)
                    || tt.soDienThoai.contains(tuKhoaHienTai);

            if (khopKhuVuc && khopTuKhoa) {
                int nhomTrangThai;
                if (dsSapSoHuu.isEmpty()) {
                    demChuaCoSap++;
                    nhomTrangThai = 0;
                } else if (soGianKhoa > 0) {
                    demCoGianKhoa++;
                    nhomTrangThai = -1;
                } else {
                    demHoatDong++;
                    nhomTrangThai = 1;
                }

                if (trangThaiLoc == null || nhomTrangThai == trangThaiLoc) {
                    ketQua.add(tt);
                }
            }
        }

        tvStatHoatDong.setText(demHoatDong + " người");
        tvStatTamNgung.setText(demChuaCoSap + " người");
        tvStatDaKhoa.setText(demCoGianKhoa + " người");

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