import 'package:family_budgeter/model/activity.dart';
import 'package:family_budgeter/model/currency.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import '../model/envelope.dart';

Future<Envelope?> showEditEnvelope(BuildContext context,
    {required Envelope envelope, bool isNew = false}) async {
  final result = await Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => EditEnvelope(envelope, isNew)),
  );
  return result;
}

class EditEnvelope extends StatefulWidget {
  final Envelope envelope;
  final bool isNew;

  EditEnvelope(this.envelope, this.isNew);

  @override
  _EditEnvelopeState createState() => _EditEnvelopeState();
}

class _EditEnvelopeState extends State<EditEnvelope> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final List<Activity> activity = widget.envelope.activity != null && widget.envelope.activity!.isNotEmpty ? [...widget.envelope.activity!] : [];
    activity.sort((a, b) => b.on!.compareTo(a.on!));
    return Scaffold(
      appBar: AppBar(
        title: Text(
            widget.isNew ? "New Envelope" : "Edit: " + widget.envelope.name),
        actions: [
          IconButton(onPressed: () => delete(context), icon: Icon(Icons.delete))
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                TextFormField(
                  initialValue: widget.envelope.name,
                  decoration: InputDecoration(
                    labelText: "Name",
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter some text";
                    }
                    return null;
                  },
                  onSaved: (value) {
                    if (value != null) {
                      widget.envelope.name = value;
                    }
                  },
                ),
                TextFormField(
                  initialValue: "${widget.envelope.amount / 100.0}",
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "Amount",
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter an amount";
                    } else if (double.tryParse(value) == null) {
                      return "Please enter a valid number";
                    }
                    return null;
                  },
                  onSaved: (value) {
                    if (value != null) {
                      final result = double.tryParse(value);
                      if (result != null) {
                        widget.envelope.amount = (result * 100.0).toInt();
                      }
                    }
                  },
                ),
                CheckboxListTile(
                  title: const Text('Allow overfill:'),
                  onChanged: (bool? value) {
                    if (value != null) {
                      setState(() {
                        widget.envelope.allowOverfill = value;
                      });
                    }
                  },
                  value: widget.envelope.allowOverfill,
                ),
                TextFormField(
                  initialValue: "${widget.envelope.refillAmount / 100.0}",
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "Refill Amount",
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter an amount";
                    } else if (double.tryParse(value) == null) {
                      return "Please enter a valid number";
                    }
                    return null;
                  },
                  onSaved: (value) {
                    if (value != null) {
                      final result = double.tryParse(value);
                      if (result != null) {
                        widget.envelope.refillAmount = (result * 100.0).toInt();
                      }
                    }
                  },
                ),
                Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Text(
                    "Every:",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                ...RefillEvery.values.map((v) {
                  return ListTile(
                    title: Text("${v.toString().split(".").last}${widget.envelope.refillEvery == v ? " (${next(widget.envelope.refillEvery)})" : ""}"),
                    leading: Radio<RefillEvery>(
                      value: v,
                      groupValue: widget.envelope.refillEvery,
                      onChanged: (RefillEvery? value) {
                        if (value != null) {
                          setState(() {
                            widget.envelope.refillEvery = value;
                          });
                        }
                      },
                    ),
                  );
                }),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState != null) {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        done(context);
                      }
                    }
                  },
                  child: const Text('Save'),
                ),
                activity.isNotEmpty ? ListView.separated(itemBuilder: (BuildContext context, int index) => ActivityWidget(activity[index]), separatorBuilder: (_, __) => const Divider(), itemCount: activity.length, shrinkWrap: true, physics: ClampingScrollPhysics(),) : Container(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void done(BuildContext context) {
    Navigator.pop(context, widget.envelope);
  }

  void delete(BuildContext context) async {
    showDialog(
      context: context,
      builder: (innerContext) => AlertDialog(
        title: Text("Delete Envelope"),
        content: Text(
            "This cannot be undone, would you still like to delete this envelope?"),
        actions: [
          OutlinedButton(
              onPressed: () {
                Navigator.pop(innerContext);
              },
              child: Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              await widget.envelope.ref!.delete();
              Navigator.pop(innerContext);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(
                primary: Colors.white, backgroundColor: Colors.red),
            child: Text("Delete"),
          ),
        ],
      ),
    );
  }

  String next(RefillEvery every) {
    switch (every) {
      case RefillEvery.day:
        return "tomorrow";
      case RefillEvery.week:
        return "next Monday";
      case RefillEvery.month:
        return "1st of next month";
      case RefillEvery.year:
        return "Jan 1st of next year";
      default:
        return "";
    }
  }
}

class ActivityWidget extends StatelessWidget {
  final DateFormat formatter = DateFormat('yyyy-MM-dd H:mm a');
  final Activity activity;

  ActivityWidget(this.activity);

  @override
  Widget build(BuildContext context) {
    final date = activity.on!.toLocal();
    return ListTile(
      dense: true,
      title: Text(activity.desc),
      subtitle: Text(formatter.format(date)),
      trailing: Text(
        amountToDollars(activity.amt),
        style: TextStyle(
            color: activity.amt > 0 ? Colors.green : Colors.redAccent),
      ),
    );
  }
}
