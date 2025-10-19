// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import '../models/phong.dart'; // Import model Phong

// // Màn hình hiển thị danh sách các phòng trống và thông tin đặt phòng
// class RoomListScreen extends StatefulWidget {
//   final List<Phong> phongs; // Danh sách tất cả các phòng trống riêng lẻ
//   final DateTime checkin;
//   final DateTime checkout;

//   const RoomListScreen({
//     super.key,
//     required this.phongs,
//     required this.checkin,
//     required this.checkout,
//   });

//   @override
//   State<RoomListScreen> createState() => _RoomListScreenState();
// }

// class _RoomListScreenState extends State<RoomListScreen> {
//   // Danh sách các phòng mà người dùng đã chọn
//   final List<Phong> _selectedRooms = [];
//   // Nhóm các phòng theo loại phòng
//   // Key: Tên loại phòng, Value: Danh sách các phòng trống thuộc loại đó
//   final Map<String, List<Phong>> _groupedRooms = {};

//   @override
//   void initState() {
//     super.initState();
//     _groupRoomTypes();
//   }

//   // Nhóm các phòng riêng lẻ theo loại phòng để quản lý số lượng
//   void _groupRoomTypes() {
//     for (var phong in widget.phongs) {
//       if (!_groupedRooms.containsKey(phong.tenLoaiPhong)) {
//         _groupedRooms[phong.tenLoaiPhong] = [];
//       }
//       _groupedRooms[phong.tenLoaiPhong]!.add(phong);
//     }
//   }

//   // Hàm xử lý khi người dùng chọn một phòng
//   void _selectRoom(String roomType) {
//     // Tìm một phòng thuộc loại được chọn mà chưa có trong _selectedRooms
//     final roomToAdd = _groupedRooms[roomType]?.firstWhere(
//       (phong) => !_selectedRooms.contains(phong)
//     );

//     if (roomToAdd != null) {
//       setState(() {
//         _selectedRooms.add(roomToAdd);
//       });
//     }
//   }

//   // Hàm xử lý khi người dùng bỏ chọn một phòng cụ thể
//   void _removeRoom(Phong room) {
//     setState(() {
//       _selectedRooms.remove(room);
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Tính toán số đêm ở, đảm bảo tối thiểu là 1 đêm
//     final int nights = widget.checkout.difference(widget.checkin).inDays > 0
//         ? widget.checkout.difference(widget.checkin).inDays
//         : 1;

//     // Lấy danh sách các loại phòng duy nhất để hiển thị
//     final roomTypes = _groupedRooms.keys.toList();

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           'Chọn Phòng',
//           style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//         ),
//         backgroundColor: const Color(0xFF007BFF),
//         iconTheme: const IconThemeData(color: Colors.white),
//       ),
//       body: Column(
//         children: [
//           // Phần danh sách các loại phòng
//           Expanded(
//             child: widget.phongs.isEmpty
//                 ? const Center(
//                     child: Text(
//                       'Không tìm thấy phòng trống nào phù hợp.',
//                       style: TextStyle(fontSize: 18, color: Colors.grey),
//                       textAlign: TextAlign.center,
//                     ),
//                   )
//                 : ListView.builder(
//                     padding: const EdgeInsets.all(16.0),
//                     itemCount: roomTypes.length,
//                     itemBuilder: (context, index) {
//                       final roomTypeName = roomTypes[index];
//                       final roomsOfType = _groupedRooms[roomTypeName]!;
//                       // Đếm số lượng phòng của loại này đã được chọn
//                       final selectedCount = _selectedRooms
//                           .where((room) => room.tenLoaiPhong == roomTypeName)
//                           .length;

//                       return RoomTypeCard(
//                         // Gửi phòng đầu tiên để lấy thông tin chung (giá, tên, ảnh...)
//                         phong: roomsOfType.first,
//                         totalAvailable: roomsOfType.length,
//                         selectedCount: selectedCount,
//                         onSelect: () => _selectRoom(roomTypeName),
//                       );
//                     },
//                   ),
//           ),
//           // Phần thông tin đặt phòng (chỉ hiển thị khi có phòng được chọn)
//           if (_selectedRooms.isNotEmpty)
//             BookingSummaryCard(
//               selectedRooms: _selectedRooms,
//               checkin: widget.checkin,
//               checkout: widget.checkout,
//               nights: nights,
//               onRemoveRoom: _removeRoom,
//             ),
//         ],
//       ),
//     );
//   }
// }

// // Widget hiển thị thẻ cho một loại phòng
// class RoomTypeCard extends StatelessWidget {
//   final Phong phong; // Dùng để hiển thị thông tin chung
//   final int totalAvailable; // Tổng số phòng trống của loại này
//   final int selectedCount; // Số lượng đã được chọn
//   final VoidCallback onSelect;

//   const RoomTypeCard({
//     super.key,
//     required this.phong,
//     required this.totalAvailable,
//     required this.selectedCount,
//     required this.onSelect,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final currencyFormatter =
//         NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
//     final defaultImageUrl =
//         'https://placehold.co/600x400/E5E5E5/000000?text=${phong.tenLoaiPhong.replaceAll(' ', '+')}';
    
//     // Kiểm tra xem có thể chọn thêm phòng loại này không
//     final bool canSelectMore = selectedCount < totalAvailable;
//     final int remaining = totalAvailable - selectedCount;

//     return Card(
//       margin: const EdgeInsets.only(bottom: 16.0),
//       elevation: 4,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       clipBehavior: Clip.antiAlias,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Image.network(
//             phong.hinhAnhUrl ?? defaultImageUrl,
//             height: 200,
//             width: double.infinity,
//             fit: BoxFit.cover,
//           ),
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   phong.tenLoaiPhong,
//                   style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//                 ),
//                 const SizedBox(height: 8),
//                 Row(
//                   children: [
//                     _buildInfoChip(Icons.king_bed_outlined, '${phong.soGiuong} giường'),
//                     const SizedBox(width: 8),
//                     _buildInfoChip(Icons.person_outline, '${phong.sucChua} người'),
//                   ],
//                 ),
//                 const SizedBox(height: 12),
//                 Text(
//                   'Số lượng còn lại: $remaining phòng',
//                   style: TextStyle(
//                     fontSize: 14,
//                     color: remaining > 0 ? Colors.green.shade700 : Colors.red,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     Text(
//                       '${currencyFormatter.format(phong.gia)} / đêm',
//                       style: const TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: Color(0xFF007BFF),
//                       ),
//                     ),
//                     ElevatedButton(
//                       onPressed: canSelectMore ? onSelect : null,
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: const Color(0xFFFFC107),
//                         disabledBackgroundColor: Colors.grey[400],
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                       ),
//                       child: Text(
//                         canSelectMore ? 'Chọn Phòng' : 'Hết Phòng',
//                         style: const TextStyle(
//                             color: Colors.black, fontWeight: FontWeight.bold),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildInfoChip(IconData icon, String label) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//       decoration: BoxDecoration(
//         color: const Color(0xFFE9ECEF),
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: Row(
//         children: [
//           Icon(icon, size: 16, color: const Color(0xFF495057)),
//           const SizedBox(width: 6),
//           Text(label, style: const TextStyle(color: Color(0xFF495057))),
//         ],
//       ),
//     );
//   }
// }

// // Widget hiển thị thẻ tóm tắt thông tin đặt phòng
// class BookingSummaryCard extends StatelessWidget {
//   final List<Phong> selectedRooms;
//   final DateTime checkin;
//   final DateTime checkout;
//   final int nights;
//   final Function(Phong) onRemoveRoom;

//   const BookingSummaryCard({
//     super.key,
//     required this.selectedRooms,
//     required this.checkin,
//     required this.checkout,
//     required this.nights,
//     required this.onRemoveRoom,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final currencyFormatter =
//         NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
//     final dateFormatter = DateFormat('dd/MM/yyyy');

//     // Tính tổng tiền
//     final double totalCost = selectedRooms.fold(
//         0, (sum, room) => sum + (room.gia * nights));

//     return Card(
//       margin: const EdgeInsets.all(8.0),
//       elevation: 8,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'Thông tin đặt phòng',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             const Divider(height: 20),
//             _buildInfoRow('Ngày nhận phòng:', dateFormatter.format(checkin)),
//             _buildInfoRow('Ngày trả phòng:', dateFormatter.format(checkout)),
//             const SizedBox(height: 10),
//             const Text(
//               'Phòng đã chọn:',
//               style: TextStyle(fontWeight: FontWeight.bold),
//             ),
//             ...selectedRooms.map((room) => ListTile(
//                   contentPadding: EdgeInsets.zero,
//                   title: Text('${room.tenLoaiPhong} - ${room.soPhong}'),
//                   trailing: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Text(currencyFormatter.format(room.gia * nights)),
//                       IconButton(
//                         icon: const Icon(Icons.delete, color: Colors.red),
//                         onPressed: () => onRemoveRoom(room),
//                       ),
//                     ],
//                   ),
//                 )),
//             const Divider(height: 20),
//             _buildInfoRow('Tổng số đêm:', '$nights đêm'),
//             _buildInfoRow(
//               'Tổng cộng:',
//               currencyFormatter.format(totalCost),
//               isTotal: true,
//             ),
//             const SizedBox(height: 16),
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: () {
//                   // TODO: Navigate to payment screen
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.green,
//                   padding: const EdgeInsets.symmetric(vertical: 16),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//                 child: const Text(
//                   'ĐẶT NGAY',
//                   style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white,
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildInfoRow(String label, String value, {bool isTotal = false}) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4.0),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             label,
//             style: TextStyle(
//               fontSize: isTotal ? 18 : 16,
//               fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
//             ),
//           ),
//           Text(
//             value,
//             style: TextStyle(
//               fontSize: isTotal ? 18 : 16,
//               fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
//               color: isTotal ? Colors.green : Colors.black,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

