import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucy_assignment/src/core/utils/extensions/context_extension.dart';

import 'package:lucy_assignment/src/feature/stock_detail/presentation/widgets/section_widget.dart';

class DetailsSection extends StatefulWidget {
  const DetailsSection({super.key});

  @override
  State<DetailsSection> createState() => _DetailsSectionState();
}

class _DetailsSectionState extends State<DetailsSection> {
  final List<_Item> _data = [
    _Item(headerValue: "Financial Performance"),
    _Item(
      headerValue: "Recent News",
      isExpanded: true,
      body: Row(
        children: [
          Container(width: 60, height: 60, color: Colors.grey[200]),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Samsung announces Samsung announces Q3 profit jump...Samsung announces Q3 profit jump...Samsung announces Q3 profit jump...Samsung announces Q3 profit jump...Samsung announces Q3 profit jump...Samsung announces Q3 profit jump...Samsung announces Q3 profit jump...Samsung announces Q3 profit jump...Samsung announces Q3 profit jump...Samsung announces Q3 profit jump...Samsung announces Q3 profit jump...",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  "2 hours ago",
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
    _Item(headerValue: "Dividends"),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: SectionHeader(title: context.l10n.details),
          ),
          ExpansionPanelList(
            elevation: 0,
            expandedHeaderPadding: EdgeInsets.zero,
            expansionCallback: (int index, bool isExpanded) {
              setState(() {
                _data[index].isExpanded = isExpanded;
              });
            },
            children: _data.map<ExpansionPanel>((_Item item) {
              return ExpansionPanel(
                headerBuilder: (BuildContext context, bool isExpanded) {
                  return ListTile(
                    title: Text(
                      item.headerValue,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  );
                },
                body: item.body != null
                    ? Container(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: item.body,
                      )
                    : const SizedBox(),
                isExpanded: item.isExpanded,
                canTapOnHeader: true,
                splashColor: Colors.transparent,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _Item {
  _Item({required this.headerValue, this.body, this.isExpanded = false});

  String headerValue;
  Widget? body;
  bool isExpanded;
}
