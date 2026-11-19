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
        dsSap.add(new SapHang("RC-01", "Rau củ", "Cô Tư Rau", 1));
        dsSap.add(new SapHang("RC-02", "Rau củ", "Chị Lan Củ", 1));
        dsSap.add(new SapHang("RC-03", "Rau củ", "", 0));
        dsSap.add(new SapHang("TC-01", "Thịt cá", "Anh Ba Thịt", 1));
        dsSap.add(new SapHang("TC-02", "Thịt cá", "Chú Sáu Cá", 2, "Đang sửa chữa hệ thống cấp thoát nước"));
        dsSap.add(new SapHang("TC-03", "Thịt cá", "", 0));
        dsSap.add(new SapHang("DK-01", "Đồ khô", "Bà Năm Mắm", 1));
        dsSap.add(new SapHang("DK-02", "Đồ khô", "", 0));
        dsSap.add(new SapHang("GD-01", "Đồ gia dụng", "Chú Tám Nhựa", 1));
        dsSap.add(new SapHang("GD-02", "Đồ gia dụng", "Cô Hoa Nồi", 1));
        dsSap.add(new SapHang("GD-03", "Đồ gia dụng", "", 0));

        dsTieuThuong.clear();

        TieuThuong tt1 = new TieuThuong("TT-01", "Cô Tư Rau", "0901234501", "RC-01", "Rau củ", 1, "");
        dsTieuThuong.add(tt1);

        TieuThuong tt2 = new TieuThuong("TT-02", "Chị Lan Củ", "0901234502", "RC-02", "Rau củ", 1, "");
        tt2.lichSuViPham.add("12/10/2026 - Bày hàng lấn vạch kẻ lối đi - Nhắc nhở");
        dsTieuThuong.add(tt2);

        TieuThuong tt3 = new TieuThuong("TT-03", "Anh Ba Thịt", "0901234503", "TC-01", "Thịt cá", 1, "");
        dsTieuThuong.add(tt3);

        TieuThuong tt4 = new TieuThuong("TT-04", "Chú Sáu Cá", "0901234504", "TC-02", "Thịt cá", 0, "Xin nghỉ phép 1 tuần vì việc gia đình");
        dsTieuThuong.add(tt4);

        TieuThuong tt5 = new TieuThuong("TT-05", "Bà Năm Mắm", "0901234505", "DK-01", "Đồ khô", -1, "Vi phạm quy định vệ sinh an toàn thực phẩm");
        tt5.lichSuViPham.add("05/10/2026 - Không niêm yết giá bán công khai - Nhắc nhở");
        tt5.lichSuViPham.add("02/11/2026 - Xả nước thải chưa qua xử lý - Cảnh cáo");
        tt5.lichSuViPham.add("18/11/2026 - Vi phạm quy định vệ sinh an toàn thực phẩm - Khóa gian hàng");
        dsTieuThuong.add(tt5);

        TieuThuong tt6 = new TieuThuong("TT-06", "Chú Tám Nhựa", "0901234506", "GD-01", "Đồ gia dụng", 1, "");
        dsTieuThuong.add(tt6);

        TieuThuong tt7 = new TieuThuong("TT-07", "Cô Hoa Nồi", "0901234507", "GD-02", "Đồ gia dụng", 1, "");
        dsTieuThuong.add(tt7);
    }

    public static TieuThuong timTieuThuongTheoSap(String maSap) {
        khoiTaoDuLieu();
        for (TieuThuong tt : dsTieuThuong) {
            if (tt.maSap != null && tt.maSap.equalsIgnoreCase(maSap)) {
                return tt;
            }
        }
        return null;
    }

    public static List<SapHang> layTatCaSapTrong() {
        khoiTaoDuLieu();
        List<SapHang> ketQua = new ArrayList<>();
        for (SapHang sap : dsSap) {
            if (sap.trangThai == 0) {
                ketQua.add(sap);
            }
        }
        return ketQua;
    }

    public static List<String> layMaSapTrongTheoKhuVuc(String khuVuc) {
        khoiTaoDuLieu();
        List<String> ketQua = new ArrayList<>();
        for (SapHang sap : dsSap) {
            if (sap.trangThai == 0 && sap.khuVuc.equals(khuVuc)) {
                ketQua.add(sap.maSap);
            }
        }
        return ketQua;
    }

    public static void ganTieuThuongVaoSap(String maSap, String tenTieuThuong) {
        for (SapHang sap : dsSap) {
            if (sap.maSap.equalsIgnoreCase(maSap)) {
                sap.tenTieuThuong = tenTieuThuong;
                if (sap.trangThai != 2) {
                    sap.trangThai = 1;
                }
                break;
            }
        }
    }

    public static void traLaiSapTrong(String maSap) {
        for (SapHang sap : dsSap) {
            if (sap.maSap.equalsIgnoreCase(maSap)) {
                sap.tenTieuThuong = "";
                if (sap.trangThai != 2) {
                    sap.trangThai = 0;
                }
                break;
            }
        }
    }

    public static void tamKhoaSap(String maSap, String lyDo) {
        for (SapHang sap : dsSap) {
            if (sap.maSap.equalsIgnoreCase(maSap)) {
                sap.trangThai = 2;
                sap.lyDoKhoa = lyDo;
                break;
            }
        }
    }

    public static void moKhoaSap(String maSap) {
        for (SapHang sap : dsSap) {
            if (sap.maSap.equalsIgnoreCase(maSap)) {
                TieuThuong tt = timTieuThuongTheoSap(maSap);
                sap.trangThai = (tt != null) ? 1 : 0;
                sap.tenTieuThuong = (tt != null) ? tt.hoTen : "";
                sap.lyDoKhoa = "";
                break;
            }
        }
    }
}