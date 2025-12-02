import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PointsWidget extends StatefulWidget {
  final int currentPoints;
  final int maxAmount;
  final int initialUsedPoints;
  final ValueChanged<int> onApply;
  final VoidCallback? onRemove;

  const PointsWidget({
    Key? key,
    required this.currentPoints,
    required this.maxAmount,
    required this.onApply,
    this.initialUsedPoints = 0,
    this.onRemove,
  }) : super(key: key);

  @override
  State<PointsWidget> createState() => _PointsWidgetState();
}

class _PointsWidgetState extends State<PointsWidget> {
  late int _usedPoints;
  final _numberFmt = NumberFormat.decimalPattern('vi_VN');
  final _currencyFmt = NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);

  //  ĐIỂM TỐI THIỂU
  static const int MIN_POINTS = 1000;

  @override
  void initState() {
    super.initState();
    _usedPoints = widget.initialUsedPoints;
  }

  @override
  void didUpdateWidget(covariant PointsWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialUsedPoints != oldWidget.initialUsedPoints) {
      setState(() {
        _usedPoints = widget.initialUsedPoints;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    //  CHỈ CHO DÙNG KHI CÓ ÍT NHẤT 1000 ĐIỂM
    final canUse = widget.currentPoints >= MIN_POINTS && _usedPoints == 0;
    final usedMoney = _usedPoints;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.stars, color: Colors.amber.shade700, size: 18),
            const SizedBox(width: 8),
            Text(
              'Điểm của bạn:',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
            ),
            const SizedBox(width: 6),
            Text(
              '${_numberFmt.format(widget.currentPoints)} điểm',
              style: const TextStyle(
                fontSize: 14, 
                fontWeight: FontWeight.bold, 
                color: Colors.blue
              ),
            ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: canUse ? () => _showUsePointsDialog(context) : null,
              icon: const Icon(Icons.discount, size: 16),
              label: const Text('Sử dụng điểm'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey.shade300,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
            ),
          ],
        ),

        //  HIỂN THỊ WARNING NẾU KHÔNG ĐỦ ĐIỂM TỐI THIỂU
        if (widget.currentPoints > 0 && widget.currentPoints < MIN_POINTS && _usedPoints == 0) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.orange.shade700, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Cần tối thiểu ${_numberFmt.format(MIN_POINTS)} điểm để sử dụng',
                    style: TextStyle(
                      fontSize: 12, 
                      color: Colors.orange.shade800,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],

        if (_usedPoints > 0) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green.shade700, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Đã sử dụng ${_numberFmt.format(_usedPoints)} điểm (-${_currencyFmt.format(usedMoney)})',
                    style: TextStyle(
                      fontSize: 13, 
                      color: Colors.green.shade700, 
                      fontWeight: FontWeight.w600
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () {
                    setState(() {
                      _usedPoints = 0;
                    });
                    if (widget.onRemove != null) widget.onRemove!();
                    widget.onApply(0);
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  color: Colors.red,
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

    void _showUsePointsDialog(BuildContext scaffoldContext) {
    final controller = TextEditingController();
    int pointsToUse = 0;

    showDialog(
      context: scaffoldContext,
      barrierDismissible: false,
      builder: (dialogContext) => WillPopScope(
        onWillPop: () async => false,
        child: StatefulBuilder(
          builder: (context, setDialogState) {
            final maxAllowed = widget.maxAmount.clamp(MIN_POINTS, widget.currentPoints);
            
            //  GỢI Ý CHỈ HIỂN THỊ CÁC MỐC >= 1000
            List<int> suggested = [1000, 5000, 10000, 20000, 50000];
            
            //  THÊM NÚT "DÙNG HẾT" (maxAllowed)
            if (maxAllowed >= MIN_POINTS && !suggested.contains(maxAllowed)) {
              suggested.add(maxAllowed);
            }
            
            suggested = suggested
                .where((p) => p >= MIN_POINTS && p <= maxAllowed)
                .toList()
              ..sort();

            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.stars, color: Colors.amber.shade700, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Sử dụng điểm',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Điểm hiện tại:', 
                                  style: TextStyle(color: Colors.grey.shade700)),
                              Text(
                                '${_numberFmt.format(widget.currentPoints)} điểm',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Tối đa có thể dùng:', 
                                  style: TextStyle(color: Colors.grey.shade700)),
                              Text(
                                '${_numberFmt.format(maxAllowed)} điểm',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange.shade700,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 12),
                    const Text(
                      'Số điểm muốn sử dụng',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    
                    TextField(
                      controller: controller,
                      keyboardType: TextInputType.number,
                      autofocus: false,
                      decoration: InputDecoration(
                        hintText: 'Nhập số điểm (tối thiểu ${_numberFmt.format(MIN_POINTS)} điểm)',
                        prefixIcon: const Icon(Icons.edit),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        suffixText: 'điểm',
                      ),
                      onChanged: (v) {
                        final parsed = int.tryParse(
                          v.replaceAll(RegExp(r'\D'), '')
                        ) ?? 0;
                        setDialogState(() => pointsToUse = parsed);
                      },
                    ),
                    
                    const SizedBox(height: 10),
                    
                    if (suggested.isNotEmpty) ...[
                      const Text(
                        'Chọn nhanh:',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: suggested.map((p) {
                          //  HIGHLIGHT NÚT "DÙNG HẾT"
                          final isMaxButton = p == maxAllowed;
                          
                          return ActionChip(
                            label: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (isMaxButton) ...[
                                  Icon(
                                    Icons.stars,
                                    size: 14,
                                    color: Colors.orange.shade700,
                                  ),
                                  const SizedBox(width: 4),
                                ],
                                Text(
                                  isMaxButton 
                                      ? 'Dùng hết (${_numberFmt.format(p)} điểm)'
                                      : '${_numberFmt.format(p)} điểm'
                                ),
                              ],
                            ),
                            onPressed: () {
                              controller.text = p.toString();
                              setDialogState(() => pointsToUse = p);
                            },
                            backgroundColor: isMaxButton 
                                ? Colors.orange.shade100 
                                : Colors.orange.shade50,
                            labelStyle: TextStyle(
                              color: Colors.orange.shade700,
                              fontWeight: isMaxButton ? FontWeight.bold : FontWeight.w600,
                              fontSize: 12,
                            ),
                            side: isMaxButton 
                                ? BorderSide(color: Colors.orange.shade700, width: 1.5)
                                : null,
                          );
                        }).toList(),
                      ),
                    ],
                    
                    const SizedBox(height: 12),
                    
                    if (pointsToUse >= MIN_POINTS && pointsToUse <= maxAllowed)
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.discount, color: Colors.green.shade700, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Giảm ${_currencyFmt.format(pointsToUse)}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green.shade700,
                                    ),
                                  ),
                                  Text(
                                    '1 điểm = 1₫',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    
                    if (pointsToUse > 0 && pointsToUse < MIN_POINTS)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.red.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.error_outline, 
                                  color: Colors.red.shade700, size: 16),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  'Số điểm tối thiểu là ${_numberFmt.format(MIN_POINTS)} điểm!',
                                  style: TextStyle(
                                    color: Colors.red.shade800,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    
                    if (pointsToUse > maxAllowed)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.orange.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.warning_amber, 
                                  color: Colors.orange.shade700, size: 16),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  'Vượt quá giới hạn! Tối đa ${_numberFmt.format(maxAllowed)} điểm.',
                                  style: TextStyle(
                                    color: Colors.orange.shade800,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    Future.microtask(() => controller.dispose());
                  },
                  child: const Text('Hủy'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final value = int.tryParse(
                      controller.text.replaceAll(RegExp(r'\D'), '')
                    ) ?? 0;
                    
                    String? errorMessage;
                    
                    if (value < MIN_POINTS) {
                      errorMessage = 'Số điểm tối thiểu là ${_numberFmt.format(MIN_POINTS)} điểm';
                    } else if (value > widget.currentPoints) {
                      errorMessage = 'Bạn chỉ có ${_numberFmt.format(widget.currentPoints)} điểm';
                    } else if (value > maxAllowed) {
                      errorMessage = 'Số điểm vượt quá giới hạn (tối đa ${_numberFmt.format(maxAllowed)} điểm)';
                    }
                    
                    if (errorMessage != null) {
                      Navigator.of(dialogContext).pop();
                      Future.microtask(() => controller.dispose());
                      
                      Future.delayed(const Duration(milliseconds: 200), () {
                        if (scaffoldContext.mounted) {
                          ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                            SnackBar(
                              content: Text(errorMessage!),
                              backgroundColor: Colors.red,
                              behavior: SnackBarBehavior.floating,
                              duration: const Duration(seconds: 3),
                            ),
                          );
                        }
                      });
                      return;
                    }

                    Navigator.of(dialogContext).pop();
                    Future.microtask(() => controller.dispose());
                    
                    if (mounted) {
                      setState(() {
                        _usedPoints = value;
                      });
                      
                      widget.onApply(value);
                      
                      Future.delayed(const Duration(milliseconds: 200), () {
                        if (scaffoldContext.mounted) {
                          ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Đã sử dụng ${_numberFmt.format(value)} điểm (-${_currencyFmt.format(value)})'
                              ),
                              backgroundColor: Colors.green,
                              behavior: SnackBarBehavior.floating,
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Áp dụng'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}