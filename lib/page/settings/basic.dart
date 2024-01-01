import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

void launchDialog(BuildContext context, double height, Widget child) {
  // final themeData = Theme.of(context);
  final mediaQuery = MediaQuery.of(context);

  showModalBottomSheet(
    context: context,
    clipBehavior: Clip.hardEdge,
    constraints: BoxConstraints(
      maxWidth: mediaQuery.size.width - 30,
      maxHeight: height
    ),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(15),
        topRight: Radius.circular(15)
      ),
    ),
    backgroundColor: Colors.transparent,
    builder: (context) => FractionallySizedBox(
      child: child,
    )
  );
}

class FancySwitch extends StatefulWidget {
  const FancySwitch({
    super.key,
    required this.title,
    required this.isEnable,
    this.onChange,
    this.lore
  });
  
  final String title;
  final bool isEnable;
  final String? lore;
  final Function(bool)? onChange;
  @override
  State<FancySwitch> createState() => _FancySwitchState();
}

class _FancySwitchState extends State<FancySwitch> {
  
  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    
    final loreText = [
      const SizedBox(height: 5),
      Flexible(
        child: Text(
          widget.lore??'',
          style: themeData.textTheme.labelSmall?.copyWith(
            color: Colors.grey
          )
        )
      )
    ];

    return Material(
      clipBehavior: Clip.hardEdge,
      borderRadius: BorderRadius.circular(15),
      color: Colors.transparent,
      child: InkWell(
        onTap: (widget.onChange == null) ? 
          null : () => widget.onChange?.call(!widget.isEnable),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.title, style: TextStyle(
                    color: (widget.onChange == null) ? Colors.grey : null
                  )),
                  (widget.lore == null) ? const SizedBox() : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: loreText
                  )
                  
                ]
              ),
              const Spacer(),
              Switch(
                value: widget.isEnable,
                onChanged: widget.onChange
              )
            ]
          )
        )
      )
    );
  }
}

class NavigationPill extends StatelessWidget {
  const NavigationPill({super.key});

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);

    return SizedBox(
      width: double.infinity,
      child: Align(
        alignment: Alignment.center,
        child: Container(
          width: 40, height: 5,
          decoration: BoxDecoration(
            color: themeData.colorScheme.primary,
            borderRadius: BorderRadius.circular(20)
          ),
        )
      )
    );
  }
}

class WarnningButton extends StatefulWidget {
  const WarnningButton({
    super.key,
    required this.errorMsg
  });

  final String? errorMsg;

  @override
  State<WarnningButton> createState() => _WarnningButtonState();
}

class _WarnningButtonState extends State<WarnningButton> {
  ToastificationItem toast = ToastificationItem(
    builder: (context, a) => const SizedBox(),
    alignment: Alignment.bottomCenter,
  );

  @override
  Widget build(BuildContext context) {
    if (widget.errorMsg == null) {
      return const SizedBox(height: 50);
    }

    return IconButton(
      icon: const Icon(
        Icons.warning_rounded,
        size: 30,
        color: Colors.yellow
      ),
      onPressed: () {
        if (toast.isRunning) return;

        toast = toastification.show(
          context: context,
          pauseOnHover: true,
          showProgressBar: false,
          title: "${widget.errorMsg}",
          autoCloseDuration: const Duration(seconds: 5),
          type: ToastificationType.error,
          alignment: Alignment.bottomCenter
        );
      }
    );
  }
}

class SectionHeading extends StatelessWidget {
  const SectionHeading({
    super.key,
    required this.title,
    required this.icon,
    this.errorMsg,
  });

  final String title;
  final IconData icon;
  final String? errorMsg;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 35),
        const SizedBox(width: 5),
        Text(title),
        const Spacer(),
        WarnningButton(errorMsg: errorMsg)
      ]
    );
  }
}