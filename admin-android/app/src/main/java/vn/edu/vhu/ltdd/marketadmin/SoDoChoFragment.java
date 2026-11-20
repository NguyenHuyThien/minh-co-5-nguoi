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

    private RecyclerView rvSoDoCho;
    private SapHangAdapter adapter;

    private CardView cardStatDaThue, cardStatSapTrong, cardStatTamKhoa;
    private TextView tvStatDaThue, tvStatSapTrong, tvStatTamKhoa, tvKhongCoKetQua;
    private Integer trangThaiLoc = null;

    private String khuVucHienTai = "Tất cả";
    private String tuKhoaHienTai = "";

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_so_do_cho, container, false);

        MarketRepository.khoiTaoDuLieu();

        rvSoDoCho = view.findViewById(R.id.rvSoDoSap);
        ChipGroup chipGroup = view.findViewById(R.id.chipGroupKhuVuc);
        EditText etTimKiem = view.findViewById(R.id.etTimKiemSap);
        ImageView btnXoaTimKiem = view.findViewById(R.id.btnXoaTimKiem);
        FloatingActionButton fabThemSap = view.findViewById(R.id.fabThemSap);

        cardStatDaThue = view.findViewById(R.id.cardStatDaThue);
        cardStatSapTrong = view.findViewById(R.id.cardStatTrong);
        cardStatTamKhoa = view.findViewById(R.id.cardStatKhoa);
        tvStatDaThue = view.findViewById(R.id.tvStatDaThue);
        tvStatSapTrong = view.findViewById(R.id.tvStatTrong);
        tvStatTamKhoa = view.findViewById(R.id.tvStatKhoa);
        tvKhongCoKetQua = view.findViewById(R.id.tvKhongCoKetQua);

        rvSoDoCho.setLayoutManager(new LinearLayoutManager(getContext()));
        adapter = new SapHangAdapter(MarketRepository.dsSap, this::hienDialogChiTietSap);
        rvSoDoCho.setAdapter(adapter);

        cardStatDaThue.setOnClickListener(v -> chonBoLocTrangThai(2));
        cardStatSapTrong.setOnClickListener(v -> chonBoLocTrangThai(0));
        cardStatTamKhoa.setOnClickListener(v -> chonBoLocTrangThai(-2));

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

    @Override
    public void onResume() {
        super.onResume();
        locDanhSach();
    }

    private void hienDialogThemSap() {
        if (getContext() == null) return;

        LinearLayout layout = new LinearLayout(getContext());
        layout.setOrientation(LinearLayout.VERTICAL);
        int pad = (int) (20 * getResources().getDisplayMetrics().density);
        layout.setPadding(pad, pad / 2, pad, 0);

        TextView tvKhuVuc = new TextView(getContext());
        tvKhuVuc.setText("Chọn khu vực quy hoạch:");
        tvKhuVuc.setTextColor(Color.parseColor("#334155"));
        tvKhuVuc.setTextSize(12f);
        layout.addView(tvKhuVuc);

        Spinner spKhuVuc = new Spinner(getContext());
        String[] dsKhuVuc = {"Rau củ", "Thịt cá", "Đồ khô", "Đồ gia dụng"};
        spKhuVuc.setAdapter(new ArrayAdapter<>(getContext(), android.R.layout.simple_spinner_dropdown_item, dsKhuVuc));
        layout.addView(spKhuVuc);

        EditText etMaSap = new EditText(getContext());
        etMaSap.setHint("Mã sạp trống mới (VD: RC-05, TC-04...)");
        etMaSap.setSingleLine(true);
        layout.addView(etMaSap);

        AlertDialog dialog = new AlertDialog.Builder(getContext())
                .setTitle("Tạo vị trí sạp trống mới")
                .setView(layout)
                .setPositiveButton("Tạo sạp", null)
                .setNegativeButton("Hủy", null)
                .create();

        dialog.setOnShowListener(d -> dialog.getButton(AlertDialog.BUTTON_POSITIVE).setOnClickListener(v -> {
            String maSap = etMaSap.getText().toString().trim().toUpperCase();
            String khuVuc = spKhuVuc.getSelectedItem().toString();

            if (maSap.isEmpty()) {
                etMaSap.setError("Vui lòng nhập mã sạp");
                return;
            }
            for (SapHang s : MarketRepository.dsSap) {
                if (s.maSap.equalsIgnoreCase(maSap)) {
                    etMaSap.setError("Mã sạp " + maSap + " đã tồn tại");
                    return;
                }
            }

            MarketRepository.dsSap.add(0, new SapHang(maSap, khuVuc, "", "", "", "", "", 0, ""));
            locDanhSach();
            rvSoDoCho.scrollToPosition(0);
            Toast.makeText(getContext(), "Đã tạo sạp trống " + maSap + " (" + khuVuc + ")", Toast.LENGTH_SHORT).show();
            dialog.dismiss();
        }));

        dialog.show();
    }

    private void hienDialogChiTietSap(SapHang sap) {
        if (getContext() == null) return;

        String tenTrangThai;
        if (sap.trangThai == 2) tenTrangThai = "Đã duyệt / Đang hoạt động";
        else if (sap.trangThai == 1) tenTrangThai = "Đang có hồ sơ chờ duyệt";
        else if (sap.trangThai == -2) tenTrangThai = "Đang tạm khóa";
        else tenTrangThai = "Sạp trống";

        StringBuilder thongTin = new StringBuilder();
        thongTin.append("Khu vực: ").append(sap.khuVuc).append("\n");
        thongTin.append("Trạng thái: ").append(tenTrangThai).append("\n");

        if (sap.trangThai == 2 || sap.trangThai == 1 || (sap.trangThai == -2 && sap.tenTieuThuong != null && !sap.tenTieuThuong.isEmpty())) {
            thongTin.append("Tên gian hàng: ").append(sap.tenGianHang).append("\n");
            thongTin.append("Chủ sạp: ").append(sap.tenTieuThuong).append(" (").append(sap.maTT).append(")\n");
            thongTin.append("SĐT liên hệ: ").append(sap.soDienThoai);
        } else {
            thongTin.append("Chủ sạp: Chưa có tiểu thương đăng ký");
        }

        if (sap.trangThai == -2 && sap.lyDo != null && !sap.lyDo.isEmpty()) {
            thongTin.append("\nLý do khóa: ").append(sap.lyDo);
        }

        String nutKhoa = (sap.trangThai == -2) ? "Mở khóa sạp" : "Khóa sạp";

        AlertDialog.Builder builder = new AlertDialog.Builder(getContext())
                .setTitle("Chi tiết Sạp " + sap.maSap)
                .setMessage(thongTin.toString())
                .setNegativeButton("Đóng", null);

        if (sap.trangThai != 1) {
            builder.setPositiveButton(nutKhoa, (dialog, which) -> {
                if (sap.trangThai == -2) {
                    MarketRepository.moKhoaSap(sap);
                    locDanhSach();
                    Toast.makeText(getContext(), "Đã mở khóa sạp " + sap.maSap, Toast.LENGTH_SHORT).show();
                } else {
                    hienDialogNhapLyDoKhoaSap(sap);
                }
            });
        }

        if (sap.trangThai == 0 || sap.trangThai == -1) {
            builder.setNeutralButton("Xóa sạp", (dialog, which) -> xacNhanXoaSap(sap));
        }

        AlertDialog dialog = builder.create();
        dialog.setOnShowListener(d -> {
            if (dialog.getButton(AlertDialog.BUTTON_NEUTRAL) != null) {
                dialog.getButton(AlertDialog.BUTTON_NEUTRAL).setTextColor(Color.parseColor("#DC2626"));
            }
        });
        dialog.show();
    }

    private void hienDialogNhapLyDoKhoaSap(SapHang sap) {
        if (getContext() == null) return;

        LinearLayout layout = new LinearLayout(getContext());
        layout.setOrientation(LinearLayout.VERTICAL);
        int pad = (int) (20 * getResources().getDisplayMetrics().density);
        layout.setPadding(pad, pad / 2, pad, 0);

        EditText etLyDoKhoa = new EditText(getContext());
        etLyDoKhoa.setHint("Nhập lý do khóa sạp / gian hàng...");
        etLyDoKhoa.setSingleLine(true);
        layout.addView(etLyDoKhoa);

        AlertDialog dialog = new AlertDialog.Builder(getContext())
                .setTitle("Khóa Sạp " + sap.maSap)
                .setView(layout)
                .setPositiveButton("Xác nhận khóa", null)
                .setNegativeButton("Hủy", null)
                .create();

        dialog.setOnShowListener(d -> dialog.getButton(AlertDialog.BUTTON_POSITIVE).setOnClickListener(v -> {
            String lyDo = etLyDoKhoa.getText().toString().trim();
            if (lyDo.isEmpty()) {
                etLyDoKhoa.setError("Vui lòng nhập lý do khóa");
                return;
            }
            MarketRepository.khoaSap(sap, lyDo);
            locDanhSach();
            Toast.makeText(getContext(), "Đã khóa sạp " + sap.maSap, Toast.LENGTH_SHORT).show();
            dialog.dismiss();
        }));

        dialog.show();
    }

    private void xacNhanXoaSap(SapHang sap) {
        if (getContext() == null) return;

        new AlertDialog.Builder(getContext())
                .setTitle("Xóa vị trí sạp")
                .setMessage("Xóa vĩnh viễn vị trí Sạp " + sap.maSap + " (" + sap.khuVuc + ") khỏi sơ đồ chợ?")
                .setPositiveButton("Xóa", (dialog, which) -> {
                    MarketRepository.dsSap.remove(sap);
                    locDanhSach();
                    Toast.makeText(getContext(), "Đã xóa Sạp " + sap.maSap, Toast.LENGTH_SHORT).show();
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
        cardStatDaThue.setCardElevation(trangThaiLoc != null && trangThaiLoc == 2 ? 8f : 0f);
        cardStatSapTrong.setCardElevation(trangThaiLoc != null && trangThaiLoc == 0 ? 8f : 0f);
        cardStatTamKhoa.setCardElevation(trangThaiLoc != null && trangThaiLoc == -2 ? 8f : 0f);

        cardStatDaThue.setAlpha(trangThaiLoc == null || trangThaiLoc == 2 ? 1.0f : 0.45f);
        cardStatSapTrong.setAlpha(trangThaiLoc == null || trangThaiLoc == 0 ? 1.0f : 0.45f);
        cardStatTamKhoa.setAlpha(trangThaiLoc == null || trangThaiLoc == -2 ? 1.0f : 0.45f);
        locDanhSach();
    }

    private void locDanhSach() {
        List<SapHang> ketQua = new ArrayList<>();
        int demDaThue = 0, demSapTrong = 0, demTamKhoa = 0;

        for (SapHang sap : MarketRepository.dsSap) {
            int trangThaiHienThi = (sap.trangThai == -1) ? 0 : sap.trangThai;

            boolean khopKhuVuc = khuVucHienTai.equals("Tất cả") || sap.khuVuc.equals(khuVucHienTai);
            boolean khopTuKhoa = tuKhoaHienTai.isEmpty()
                    || boDauTiengViet(sap.maSap).contains(tuKhoaHienTai)
                    || boDauTiengViet(sap.tenTieuThuong).contains(tuKhoaHienTai)
                    || boDauTiengViet(sap.tenGianHang).contains(tuKhoaHienTai);

            if (khopKhuVuc && khopTuKhoa) {
                if (trangThaiHienThi == 2) demDaThue++;
                else if (trangThaiHienThi == 0) demSapTrong++;
                else if (trangThaiHienThi == -2) demTamKhoa++;

                if (trangThaiLoc == null || trangThaiHienThi == trangThaiLoc) {
                    ketQua.add(sap);
                }
            }
        }

        tvStatDaThue.setText(demDaThue + " sạp");
        tvStatSapTrong.setText(demSapTrong + " sạp");
        tvStatTamKhoa.setText(demTamKhoa + " sạp");

        tvKhongCoKetQua.setVisibility(ketQua.isEmpty() ? View.VISIBLE : View.GONE);
        rvSoDoCho.setVisibility(ketQua.isEmpty() ? View.GONE : View.VISIBLE);

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
        if (text == null) return "";
        String temp = Normalizer.normalize(text, Normalizer.Form.NFD);
        Pattern pattern = Pattern.compile("\\p{InCombiningDiacriticalMarks}+");
        return pattern.matcher(temp).replaceAll("")
                .replace('đ', 'd')
                .replace('Đ', 'D')
                .toLowerCase();
    }
}