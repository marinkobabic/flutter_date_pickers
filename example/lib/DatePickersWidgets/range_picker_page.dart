import 'package:flutter/material.dart';
import 'package:flutter_date_picker/event.dart';
import 'package:flutter_date_picker/color_picker_dialog.dart';
import 'package:flutter_date_picker/color_selector_btn.dart';
import 'package:flutter_date_pickers/flutter_date_pickers.dart';

class RangePickerPage extends StatefulWidget {
  final List<Event> events;

  const RangePickerPage({Key key, this.events}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _RangePickerPageState();
}

class _RangePickerPageState extends State<RangePickerPage> {
  DateTime _firstDate;
  DateTime _lastDate;
  DatePeriod _selectedPeriod;

  Color selectedPeriodStartColor;
  Color selectedPeriodLastColor;
  Color selectedPeriodMiddleColor;

  @override
  void initState() {
    super.initState();

    _firstDate = DateTime.now().subtract(Duration(days: 45));
    _lastDate = DateTime.now().add(Duration(days: 45));

    DateTime selectedPeriodStart = DateTime.now().subtract(Duration(days: 4));
    DateTime selectedPeriodEnd = DateTime.now().add(Duration(days: 8));
    _selectedPeriod = DatePeriod(selectedPeriodStart, selectedPeriodEnd);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // defaults for styles
    selectedPeriodLastColor = Theme.of(context).accentColor;
    selectedPeriodMiddleColor = Theme.of(context).accentColor;
    selectedPeriodStartColor = Theme.of(context).accentColor;
  }

  @override
  Widget build(BuildContext context) {
    // add selected colors to default settings
    DatePickerRangeStyles styles = DatePickerRangeStyles(
      selectedPeriodLastDecoration: BoxDecoration(
          color: selectedPeriodLastColor,
          borderRadius: BorderRadius.only(
              topRight: Radius.circular(10.0),
              bottomRight: Radius.circular(10.0))),
      selectedPeriodStartDecoration: BoxDecoration(
        color: selectedPeriodStartColor,
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10.0), bottomLeft: Radius.circular(10.0)),
      ),
      selectedPeriodMiddleDecoration: BoxDecoration(
          color: selectedPeriodMiddleColor, shape: BoxShape.rectangle),
      nextIcon: Icon(Icons.arrow_right),
      prevIcon: Icon(Icons.arrow_left),
      dayHeaderStyleBuilder: _dayHeaderStyleBuilder
    );

    return Flex(
      direction: MediaQuery.of(context).orientation == Orientation.portrait
          ? Axis.vertical
          : Axis.horizontal,
      children: <Widget>[
        Expanded(
          child: RangePicker(
            selectedPeriod: _selectedPeriod,
            onChanged: _onSelectedDateChanged,
            firstDate: _firstDate,
            lastDate: _lastDate,
            datePickerStyles: styles,
            eventDecorationBuilder: _eventDecorationBuilder,
            selectableDayPredicate: _isSelectableCustom,
          ),
        ),
        Container(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  "Selected date styles",
                  style: Theme.of(context).textTheme.subtitle1,
                ),
                _stylesBlock(),
                _selectedBlock()
              ],
            ),
          ),
        ),
      ],
    );
  }

  // block witch show information about selected date and boundaries of the selected period
  Widget _selectedBlock() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _selectedPeriod != null
            ? Column(children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
                  child: Text("Selected period boundaries:"),
                ),
                Text(_selectedPeriod.start.toString()),
                Text(_selectedPeriod.end.toString()),
              ])
            : Container()
      ],
    );
  }

  // block witt color buttons insede
  Widget _stylesBlock() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ColorSelectorBtn(
              title: "Start",
              color: selectedPeriodStartColor,
              showDialogFunction: _showSelectedStartColorDialog),
          SizedBox(
            width: 12.0,
          ),
          ColorSelectorBtn(
              title: "Middle",
              color: selectedPeriodMiddleColor,
              showDialogFunction: _showSelectedMiddleColorDialog),
          SizedBox(
            width: 12.0,
          ),
          ColorSelectorBtn(
              title: "End",
              color: selectedPeriodLastColor,
              showDialogFunction: _showSelectedEndColorDialog),
        ],
      ),
    );
  }

  // select background color for the first date of the selected period
  void _showSelectedStartColorDialog() async {
    Color newSelectedColor = await showDialog(
        context: context,
        builder: (_) => ColorPickerDialog(
              selectedColor: selectedPeriodStartColor,
            ));

    if (newSelectedColor != null)
      setState(() {
        selectedPeriodStartColor = newSelectedColor;
      });
  }

  // select background color for the last date of the selected period
  void _showSelectedEndColorDialog() async {
    Color newSelectedColor = await showDialog(
        context: context,
        builder: (_) => ColorPickerDialog(
              selectedColor: selectedPeriodLastColor,
            ));

    if (newSelectedColor != null)
      setState(() {
        selectedPeriodLastColor = newSelectedColor;
      });
  }

  // select background color for the middle dates of the selected period
  void _showSelectedMiddleColorDialog() async {
    Color newSelectedColor = await showDialog(
        context: context,
        builder: (_) => ColorPickerDialog(
              selectedColor: selectedPeriodMiddleColor,
            ));

    if (newSelectedColor != null)
      setState(() {
        selectedPeriodMiddleColor = newSelectedColor;
      });
  }

  void _onSelectedDateChanged(DatePeriod newPeriod) {
    setState(() {
      _selectedPeriod = newPeriod;
    });
  }

  EventDecoration _eventDecorationBuilder(DateTime date) {
    List<DateTime> eventsDates = widget.events?.map<DateTime>((Event e) => e.date)?.toList();
    bool isEventDate = eventsDates?.any((DateTime d) => date.year == d.year && date.month == d.month && d.day == date.day) ?? false;

    BoxDecoration roundedBorder = BoxDecoration(
        border: Border.all(
          color: Colors.green,
        ),
        borderRadius: BorderRadius.all(Radius.circular(3.0))
    );

    return isEventDate
        ? EventDecoration(boxDecoration: roundedBorder)
        : null;
  }

  bool _isSelectableCustom (DateTime day) {
    return true;
//    return day.weekday < 6;
//    return day.day != DateTime.now().add(Duration(days: 7)).day ;
  }

  // 0 is Sunday, 6 is Saturday
  DayHeaderStyle _dayHeaderStyleBuilder(int weekday) {
    bool isWeekend = weekday == 0 || weekday == 6;

    return DayHeaderStyle(
        textStyle: TextStyle(
            color: isWeekend ? Colors.red : Colors.teal
        )
    );
  }
}
