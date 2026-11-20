package vn.edu.vhu.ltdd.marketadmin;

import android.graphics.Color;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;
import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;
import java.util.List;

public class TieuThuongAdapter extends RecyclerView.Adapter<TieuThuongAdapter.TieuThuongViewHolder> {

    private List<TieuThuong> listTieuThuong;
    private final OnTieuThuongClickListener listener;

    public interface OnTieuThuongClickListener {
        void onTieuThuongClick(TieuThuong tieuThuong);
    }

    public TieuThuongAdapter(List<TieuThuong> listTieuThuong, OnTieuThuongClickListener listener) {
        this.listTieuThuong = listTieuThuong;
        this.listener = listener;
    }

    public void updateData(List<TieuThuong> newList) {
        this.listTieuThuong = newList;
        notifyDataSetChanged();
    }

    @NonNull
    @Override
    public TieuThuongViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(parent.getContext()).inflate(R.layout.item_tieu_thuong, parent, false);
        return new TieuThuongViewHolder(view);
    }

    @Override
    public void onBindViewHolder(@NonNull TieuThuongViewHolder holder, int position) {
        TieuThuong tt = listTieuThuong.get(position);
        List<SapHang> dsSapSoHuu = MarketRepository.laySapCuaTieuThuong(tt.maTT);

        holder.tvMaTT.setText(tt.hoTen + " (" + tt.maTT + ")");

        if (dsSapSoHuu.isEmpty()) {
            holder.tvKhuVucNho.setText("0 gian");
            holder.tvHoTenTT.setText("Chưa có gian hàng");
        } else {
            holder.tvKhuVucNho.setText(dsSapSoHuu.size() + " gian");
            StringBuilder sbSap = new StringBuilder("Sạp sở hữu: ");
            for (int i = 0; i < dsSapSoHuu.size(); i++) {
                if (i > 0) sbSap.append(", ");
                sbSap.append(dsSapSoHuu.get(i).maSap);
            }
            holder.tvHoTenTT.setText(sbSap.toString());
        }

        holder.tvSdtTT.setText("SĐT: " + tt.soDienThoai + " • Vi phạm: " + tt.lichSuViPham.size() + " lần");

        int soBiKhoa = 0;
        StringBuilder lyDoKhoa = new StringBuilder();
        for (SapHang s : dsSapSoHuu) {
            if (s.trangThai == -2) {
                soBiKhoa++;
                if (lyDoKhoa.length() > 0) lyDoKhoa.append("; ");
                lyDoKhoa.append(s.maSap).append(": ").append(s.lyDo);
            }
        }

        if (lyDoKhoa.length() > 0) {
            holder.tvLyDoTT.setVisibility(View.VISIBLE);
            holder.tvLyDoTT.setText("Khóa " + lyDoKhoa);
        } else {
            holder.tvLyDoTT.setVisibility(View.GONE);
        }

        if (dsSapSoHuu.isEmpty()) {
            holder.tvTrangThaiTT.setText("Chưa có sạp");
            holder.tvTrangThaiTT.setTextColor(Color.parseColor("#475569"));
            holder.tvTrangThaiTT.setBackgroundColor(Color.parseColor("#E2E8F0"));
        } else if (soBiKhoa == dsSapSoHuu.size()) {
            holder.tvTrangThaiTT.setText("Đã khóa");
            holder.tvTrangThaiTT.setTextColor(Color.parseColor("#B91C1C"));
            holder.tvTrangThaiTT.setBackgroundColor(Color.parseColor("#FEE2E2"));
        } else if (soBiKhoa > 0) {
            holder.tvTrangThaiTT.setText("Khóa " + soBiKhoa + "/" + dsSapSoHuu.size());
            holder.tvTrangThaiTT.setTextColor(Color.parseColor("#B45309"));
            holder.tvTrangThaiTT.setBackgroundColor(Color.parseColor("#FEF3C7"));
        } else {
            holder.tvTrangThaiTT.setText("Hoạt động");
            holder.tvTrangThaiTT.setTextColor(Color.parseColor("#15803D"));
            holder.tvTrangThaiTT.setBackgroundColor(Color.parseColor("#DCFCE7"));
        }

        holder.itemView.setOnClickListener(v -> listener.onTieuThuongClick(tt));
    }

    @Override
    public int getItemCount() {
        return listTieuThuong.size();
    }

    static class TieuThuongViewHolder extends RecyclerView.ViewHolder {
        ImageView ivAvatarTT;
        TextView tvMaTT, tvKhuVucNho, tvHoTenTT, tvSdtTT, tvLyDoTT, tvTrangThaiTT;

        public TieuThuongViewHolder(@NonNull View itemView) {
            super(itemView);
            ivAvatarTT = itemView.findViewById(R.id.ivAvatarTT);
            tvMaTT = itemView.findViewById(R.id.tvMaTT);
            tvKhuVucNho = itemView.findViewById(R.id.tvKhuVucNho);
            tvHoTenTT = itemView.findViewById(R.id.tvHoTenTT);
            tvSdtTT = itemView.findViewById(R.id.tvSdtTT);
            tvLyDoTT = itemView.findViewById(R.id.tvLyDoTT);
            tvTrangThaiTT = itemView.findViewById(R.id.tvTrangThaiTT);
        }
    }
}