package vn.edu.vhu.ltdd.marketadmin;

import java.util.ArrayList;
import java.util.List;

public class MarketRepository {
    public static final List<SapHang> dsSap = new ArrayList<>();
    public static final List<TieuThuong> dsTieuThuong = new ArrayList<>();
    private static boolean daKhoiTao = false;

    public static void khoiTaoDuLieu() {
        if (daKhoiTao) return;
        daKhoiTao = true;

        dsSap.clear();
        dsSap.add(new SapHang("RC-01", "Rau củ", "Rau Sạch Cô Tư", "TT-01", "Cô Tư Rau", "0901234501", "01/09/2026", 2, ""));
        dsSap.add(new SapHang("RC-02", "Rau củ", "Củ Quả Đà Lạt Lan", "TT-02", "Chị Lan Củ", "0901234502", "03/09/2026", 2, ""));
        dsSap.add(new SapHang("RC-03", "Rau củ", "Rau Hữu Cơ Bé Hai", "TT-07", "Nguyễn Thị Bé Hai", "0909888771", "19/11/2026", 1, ""));
        dsSap.add(new SapHang("RC-04", "Rau củ", "", "", "", "", "", 0, ""));

        dsSap.add(new SapHang("TC-01", "Thịt cá", "Thịt Heo Tươi Anh Ba", "TT-03", "Anh Ba Thịt", "0901234503", "05/09/2026", 2, ""));
        dsSap.add(new SapHang("TC-02", "Thịt cá", "Hải Sản Chú Sáu", "TT-04", "Chú Sáu Cá", "0901234504", "10/09/2026", -2, "Đang sửa chữa hệ thống cấp thoát nước"));
        dsSap.add(new SapHang("TC-03", "Thịt cá", "Cá Đồng Tươi Anh Tư", "TT-08", "Lê Văn Tư", "0909888772", "20/11/2026", 1, ""));

        dsSap.add(new SapHang("DK-01", "Đồ khô", "Đặc Sản Mắm Bà Năm", "TT-05", "Bà Năm Mắm", "0901234505", "12/09/2026", -2, "Vi phạm quy định vệ sinh an toàn thực phẩm"));
        dsSap.add(new SapHang("DK-02", "Đồ khô", "Đồ Khô Tổng Hợp Cô Tư", "TT-01", "Cô Tư Rau", "0901234501", "20/11/2026", 1, ""));
        dsSap.add(new SapHang("DK-03", "Đồ khô", "", "", "", "", "", 0, ""));

        dsSap.add(new SapHang("GD-01", "Đồ gia dụng", "Nhựa Gia Dụng Chú Tám", "TT-06", "Chú Tám Nhựa", "0901234506", "20/09/2026", 2, ""));
        dsSap.add(new SapHang("GD-02", "Đồ gia dụng", "Gia Dụng Tiện Ích Cô Tư", "TT-01", "Cô Tư Rau", "0901234501", "15/10/2026", 2, ""));
        dsSap.add(new SapHang("GD-03", "Đồ gia dụng", "Gia Dụng Giá Rẻ Minh", "TT-09", "Trần Văn Minh", "0909888773", "18/11/2026", -1, "Hồ sơ thiếu giấy chứng nhận đăng ký kinh doanh"));

        dsTieuThuong.clear();
        TieuThuong tt1 = new TieuThuong("TT-01", "Cô Tư Rau", "0901234501");
        TieuThuong tt2 = new TieuThuong("TT-02", "Chị Lan Củ", "0901234502");
        tt2.lichSuViPham.add("12/10/2026 - Bày hàng lấn vạch kẻ lối đi - Nhắc nhở");
        TieuThuong tt3 = new TieuThuong("TT-03", "Anh Ba Thịt", "0901234503");
        TieuThuong tt4 = new TieuThuong("TT-04", "Chú Sáu Cá", "0901234504");
        TieuThuong tt5 = new TieuThuong("TT-05", "Bà Năm Mắm", "0901234505");
        tt5.lichSuViPham.add("05/10/2026 - Không niêm yết giá bán công khai - Nhắc nhở");
        tt5.lichSuViPham.add("18/11/2026 - Vi phạm quy định vệ sinh an toàn thực phẩm - Khóa gian hàng");
        TieuThuong tt6 = new TieuThuong("TT-06", "Chú Tám Nhựa", "0901234506");

        dsTieuThuong.add(tt1);
        dsTieuThuong.add(tt2);
        dsTieuThuong.add(tt3);
        dsTieuThuong.add(tt4);
        dsTieuThuong.add(tt5);
        dsTieuThuong.add(tt6);
    }

    public static List<SapHang> laySapCuaTieuThuong(String maTT) {
        khoiTaoDuLieu();
        List<SapHang> ketQua = new ArrayList<>();
        for (SapHang sap : dsSap) {
            if (sap.maTT != null && sap.maTT.equalsIgnoreCase(maTT) && (sap.trangThai == 2 || sap.trangThai == -2)) {
                ketQua.add(sap);
            }
        }
        return ketQua;
    }

    public static TieuThuong timTieuThuongTheoMa(String maTT) {
        khoiTaoDuLieu();
        for (TieuThuong tt : dsTieuThuong) {
            if (tt.maTT.equalsIgnoreCase(maTT)) {
                return tt;
            }
        }
        return null;
    }

    public static void duyetHoSoSap(SapHang sap) {
        sap.trangThai = 2;
        sap.lyDo = "";
        TieuThuong tt = timTieuThuongTheoMa(sap.maTT);
        if (tt == null) {
            dsTieuThuong.add(new TieuThuong(sap.maTT, sap.tenTieuThuong, sap.soDienThoai));
        }
    }

    public static void tuChoiHoSoSap(SapHang sap, String lyDo) {
        sap.trangThai = -1;
        sap.lyDo = lyDo;
    }

    public static void traSapVeTrong(SapHang sap) {
        sap.tenGianHang = "";
        sap.maTT = "";
        sap.tenTieuThuong = "";
        sap.soDienThoai = "";
        sap.ngayDangKy = "";
        sap.trangThai = 0;
        sap.lyDo = "";
    }

    public static void khoaSap(SapHang sap, String lyDo) {
        sap.trangThai = -2;
        sap.lyDo = lyDo;
    }

    public static void moKhoaSap(SapHang sap) {
        sap.trangThai = (sap.maTT != null && !sap.maTT.isEmpty()) ? 2 : 0;
        sap.lyDo = "";
    }
}