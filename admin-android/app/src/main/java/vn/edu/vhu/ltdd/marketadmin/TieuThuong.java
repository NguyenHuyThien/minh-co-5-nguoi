package vn.edu.vhu.ltdd.marketadmin;

import java.util.ArrayList;
import java.util.List;

public class TieuThuong {
    public String maTT;
    public String hoTen;
    public String soDienThoai;
    public List<String> lichSuViPham;

    public TieuThuong(String maTT, String hoTen, String soDienThoai) {
        this.maTT = maTT;
        this.hoTen = hoTen;
        this.soDienThoai = soDienThoai;
        this.lichSuViPham = new ArrayList<>();
    }
}