package vn.edu.vhu.ltdd.marketadmin;

import android.graphics.Color;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;
import androidx.annotation.NonNull;
import androidx.cardview.widget.CardView;
import androidx.recyclerview.widget.RecyclerView;
import java.util.List;

public class SapHangAdapter extends RecyclerView.Adapter<SapHangAdapter.SapViewHolder> {

    private List<SapHang> listSap;
    private final OnSapClickListener listener;

    public interface OnSapClickListener {
        void onSapClick(SapHang sap);
    }

    public SapHangAdapter(List<SapHang> listSap, OnSapClickListener listener) {
        this.listSap = listSap;
        this.listener = listener;
    }

    public void updateData(List<SapHang> newList) {
        this.listSap = newList;
        notifyDataSetChanged();
    }

    @NonNull
    @Override
    public SapViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(parent.getContext()).inflate(R.layout.item_vi_tri_sap, parent, false);
        return new SapViewHolder(view);
    }

    @Override
    public void onBindViewHolder(@NonNull SapViewHolder holder, int position) {
        SapHang sap = listSap.get(position);
        holder.tvMaSap.setText("Sạp " + sap.maSap);
        holder.tvKhuVucLabel.setText(sap.khuVuc);

        TieuThuong ttDangKy = MarketRepository.timTieuThuongTheoSap(sap.maSap);
        if (sap.trangThai == 2 && sap.lyDoKhoa != null && !sap.lyDoKhoa.isEmpty()) {
            holder.tvChuSap.setText("Khóa mặt bằng: " + sap.lyDoKhoa);
            holder.tvChuSap.setTextColor(Color.parseColor("#B91C1C"));
        } else if (ttDangKy != null) {
            if (ttDangKy.trangThai == -1) {
                holder.tvChuSap.setText("Chủ sạp: " + ttDangKy.hoTen + " • Đã khóa gian hàng");
                holder.tvChuSap.setTextColor(Color.parseColor("#B91C1C"));
            } else if (ttDangKy.trangThai == 0) {
                holder.tvChuSap.setText("Chủ sạp: " + ttDangKy.hoTen + " • Tạm ngưng");
                holder.tvChuSap.setTextColor(Color.parseColor("#B45309"));
            } else {
                holder.tvChuSap.setText("Chủ sạp: " + ttDangKy.hoTen + " (" + ttDangKy.maTT + ")");
                holder.tvChuSap.setTextColor(Color.parseColor("#64748B"));
            }
        } else {
            holder.tvChuSap.setText("Chưa có tiểu thương đăng ký");
            holder.tvChuSap.setTextColor(Color.parseColor("#64748B"));
        }

        switch (sap.khuVuc) {
            case "Rau củ":
                holder.tvEmojiKhuVuc.setText("🥬");
                holder.cardIconBg.setCardBackgroundColor(Color.parseColor("#DCFCE7"));
                break;
            case "Thịt cá":
                holder.tvEmojiKhuVuc.setText("🥩");
                holder.cardIconBg.setCardBackgroundColor(Color.parseColor("#FEE2E2"));
                break;
            case "Đồ khô":
                holder.tvEmojiKhuVuc.setText("🥜");
                holder.cardIconBg.setCardBackgroundColor(Color.parseColor("#FEF3C7"));
                break;
            default:
                holder.tvEmojiKhuVuc.setText("🍳");
                holder.cardIconBg.setCardBackgroundColor(Color.parseColor("#E0E7FF"));
                break;
        }

        if (sap.trangThai == 1) {
            holder.tvTrangThaiBadge.setText("Đã thuê");
            holder.tvTrangThaiBadge.setTextColor(Color.parseColor("#15803D"));
            holder.cardTrangThaiBadge.setCardBackgroundColor(Color.parseColor("#DCFCE7"));
        } else if (sap.trangThai == 0) {
            holder.tvTrangThaiBadge.setText("Sạp trống");
            holder.tvTrangThaiBadge.setTextColor(Color.parseColor("#475569"));
            holder.cardTrangThaiBadge.setCardBackgroundColor(Color.parseColor("#E2E8F0"));
        } else {
            holder.tvTrangThaiBadge.setText("Tạm khóa");
            holder.tvTrangThaiBadge.setTextColor(Color.parseColor("#B91C1C"));
            holder.cardTrangThaiBadge.setCardBackgroundColor(Color.parseColor("#FEE2E2"));
        }

        holder.itemView.setOnClickListener(v -> listener.onSapClick(sap));
    }

    @Override
    public int getItemCount() {
        return listSap.size();
    }

    static class SapViewHolder extends RecyclerView.ViewHolder {
        CardView cardIconBg, cardTrangThaiBadge;
        TextView tvEmojiKhuVuc, tvMaSap, tvKhuVucLabel, tvChuSap, tvTrangThaiBadge;

        public SapViewHolder(@NonNull View itemView) {
            super(itemView);
            cardIconBg = itemView.findViewById(R.id.cardIconBg);
            cardTrangThaiBadge = itemView.findViewById(R.id.cardTrangThaiBadge);
            tvEmojiKhuVuc = itemView.findViewById(R.id.tvEmojiKhuVuc);
            tvMaSap = itemView.findViewById(R.id.tvMaSap);
            tvKhuVucLabel = itemView.findViewById(R.id.tvKhuVucLabel);
            tvChuSap = itemView.findViewById(R.id.tvChuSap);
            tvTrangThaiBadge = itemView.findViewById(R.id.tvTrangThaiBadge);
        }
    }
}