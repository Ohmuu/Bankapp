import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:ui' as ui;
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;

class TransactionReceipt extends StatefulWidget {
  final Color darkBlue = Color(0xFF16213E);
  final Color darkPurple = Color(0xFF533483);
  final String transactionId;
  final String type;
  final double amount;
  final Timestamp? timestamp;
  final String description;
  final String category;
  final String? note;
  final String? recipient;

  final String? sender;
  TransactionReceipt({
    required this.transactionId,
    required this.type,
    required this.amount,
    required this.timestamp,
    required this.description,
    required this.category,
    required this.note,
    required this.recipient,

    required this.sender,
  });

  @override
  State<TransactionReceipt> createState() => _TransactionReceiptState();
}

class _TransactionReceiptState extends State<TransactionReceipt> {
  final GlobalKey _receiptKey = GlobalKey();
  bool _isSharing = false;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Transaction Receipt",
            style: TextStyle(color: Colors.white),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          backgroundColor: widget.darkPurple,
          actions: [
            IconButton(
              icon: Icon(Icons.share, color: Colors.white),
              onPressed: _isSharing ? null : _shareReceipt,
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(16),
                child: RepaintBoundary(key: _receiptKey, child: buildReceipt()),
              ),
              buildActionButton(),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildReceipt() {
    final isDebit = widget.type == 'debit';
    final amountColor = isDebit ? Colors.red : Colors.green;
    final amountText =
        '${isDebit ? '-' : '+'}${widget.amount.toStringAsFixed(2)}';

    String formattedDetails = 'Unknown date';
    if (widget.timestamp != null) {
      final date = DateFormat(
        'MMM dd, yyyy',
      ).format(widget.timestamp!.toDate());
      final time = DateFormat('hh:mm a').format(widget.timestamp!.toDate());
      formattedDetails = '$date at $time';
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(24),
            child: Column(
              children: [
                Icon(
                  isDebit ? Icons.arrow_upward : Icons.arrow_downward,
                  size: 48,
                  color: amountColor,
                ),
                SizedBox(height: 16),
                Text(
                  amountText,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: amountColor,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  widget.description,
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                SizedBox(height: 24),
                buildStatus(),
                SizedBox(height: 24),
                Divider(color: Colors.grey[300]),
                SizedBox(height: 24),
                buildDetailRow('Date', formattedDetails),
                buildDetailRow('Category', widget.category),
                if (widget.note != null && widget.note!.isNotEmpty)
                  buildDetailRow('Note', widget.note!),
                if (isDebit && widget.recipient != null)
                  buildDetailRow('To', widget.recipient!),
                if (!isDebit && widget.sender != null)
                  buildDetailRow('From', widget.sender!),
                buildDetailRow(
                  'Transaction ID',
                  widget.transactionId.length > 12
                      ? widget.transactionId.substring(0, 12)
                      : widget.transactionId,
                ),
                buildDetailRow('Note', widget.note ?? '-'),
                Divider(color: Colors.grey[300]),

                //amount
                Column(
                  children: [
                    Text(
                      'Amount Details',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    buildDetailRow('Amount', widget.amount.toStringAsFixed(2)),
                    buildDetailRow('Fee', '0.00'),
                    buildDetailRow('Total', widget.amount.toStringAsFixed(2)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 16, color: Colors.grey[600])),
          SizedBox(width: 8),
          Text(
            value,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget buildStatus() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle, color: Colors.green, size: 20),
          SizedBox(width: 8),
          Text(
            'Completed',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  //share and done botton
  Widget buildActionButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          //Share Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.darkPurple,
                foregroundColor: Colors.white,
              ),
              onPressed: _isSharing ? null : _shareReceipt,
              icon: _isSharing
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(Icons.share),
              label: Text("Share"),
            ),
          ),

          //Done Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: widget.darkPurple,
                side: BorderSide(color: widget.darkPurple),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Done"),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _shareReceipt() async {
    if (_isSharing) return;
    setState(() {
      _isSharing = true;
    });

    try {
      //capture the reciept as image
      final boundary =
          _receiptKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary == null) return;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData?.buffer.asUint8List();

      if (kIsWeb) {
        await Share.shareXFiles([
          XFile.fromData(
            pngBytes!,
            name: 'receipt_${widget.transactionId}.png',
            mimeType: 'image/png',
          ),
        ], text: "Here is the transaction receipt");
      } else {
        //mobile platform
        final tempDir = await getTemporaryDirectory();
        final file = File(
          '${tempDir.path}/receipt_${widget.transactionId}.png',
        );
        await file.writeAsBytes(pngBytes!);

        //share the file
        await Share.shareXFiles([
          XFile(file.path, mimeType: 'image/png'),
        ], text: "Here is the transaction receipt");
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to share receipt: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSharing = false;
        });
      }
    }
  }
}
