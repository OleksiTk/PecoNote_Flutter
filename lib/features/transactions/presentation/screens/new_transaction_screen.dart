import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/app_buttons.dart';
import '../../../../shared/widgets/gradient_background.dart';
import '../../../accounts/application/providers/accounts_providers.dart';
import '../../application/providers/transactions_providers.dart';
import '../../domain/entities/receipt_ocr_result.dart';
import '../models/transaction_draft.dart';

class NewTransactionScreen extends ConsumerStatefulWidget {
  const NewTransactionScreen({super.key});

  @override
  ConsumerState<NewTransactionScreen> createState() =>
      _NewTransactionScreenState();
}

class _NewTransactionScreenState extends ConsumerState<NewTransactionScreen> {
  TransactionKind _kind = TransactionKind.expense;
  String _whole = '0';
  String? _decimal;
  bool _scanningReceipt = false;
  String? _scanError;

  bool get _hasAmount => _whole != '0' || (_decimal?.isNotEmpty ?? false);

  void _pressDigit(String digit) {
    setState(() {
      if (_decimal != null) {
        if (_decimal!.length < 2) _decimal = '$_decimal$digit';
      } else {
        _whole = _whole == '0' ? digit : '$_whole$digit';
      }
    });
  }

  void _pressComma() {
    setState(() => _decimal ??= '');
  }

  void _pressBackspace() {
    setState(() {
      if (_decimal != null) {
        if (_decimal!.isNotEmpty) {
          _decimal = _decimal!.substring(0, _decimal!.length - 1);
        } else {
          _decimal = null;
        }
      } else if (_whole.length > 1) {
        _whole = _whole.substring(0, _whole.length - 1);
      } else {
        _whole = '0';
      }
    });
  }

  void _goBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.goNamed(AppRoute.home.name);
    }
  }

  Future<void> _scanReceipt() async {
    final photo = await ImagePicker().pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );
    if (photo == null) return;

    setState(() {
      _scanningReceipt = true;
      _scanError = null;
    });
    try {
      final dataSource = ref.read(receiptOcrRemoteDataSourceProvider);
      final json = await dataSource.extract(File(photo.path));
      final result = ReceiptOcrResult.fromJson(json);

      if (result.amount != null && result.amount! > 0) {
        final fixed = result.amount!.toStringAsFixed(2);
        final dotIndex = fixed.indexOf('.');
        setState(() {
          _whole = fixed.substring(0, dotIndex);
          _decimal = fixed.substring(dotIndex + 1);
        });
      }

      if (!mounted) return;
      final accounts = ref.read(accountsProvider).value ?? const [];
      final account = accounts.isEmpty ? null : accounts.first;
      context.pushNamed(
        AppRoute.transactionDetails.name,
        extra: TransactionDraft(
          kind: TransactionKind.expense,
          wholeAmount: _whole,
          decimalAmount: (_decimal ?? '').padRight(2, '0'),
          accountLabel: account?.name ?? 'No account yet',
          accountId: account?.id,
          initialNote: result.merchantName,
          initialDate: result.date,
        ),
      );
    } on DioException catch (error) {
      setState(() => _scanError = _scanErrorMessage(error));
    } catch (_) {
      setState(
        () => _scanError =
            'Could not read this receipt. Try again or enter it manually.',
      );
    } finally {
      if (mounted) setState(() => _scanningReceipt = false);
    }
  }

  String _scanErrorMessage(DioException error) {
    final status = error.response?.statusCode;
    if (status == 503) return 'Receipt scanning is not available right now.';
    if (status == 502) {
      return 'Could not read this receipt. Try entering it manually.';
    }
    return 'Could not scan the receipt. Check your connection and try again.';
  }

  void _next() {
    final accounts = ref.read(accountsProvider).value ?? const [];
    final account = accounts.isEmpty ? null : accounts.first;
    context.pushNamed(
      AppRoute.transactionDetails.name,
      extra: TransactionDraft(
        kind: _kind,
        wholeAmount: _whole,
        decimalAmount: (_decimal ?? '').padRight(2, '0'),
        accountLabel: account?.name ?? 'No account yet',
        accountId: account?.id,
      ),
    );
  }

  String get _groupedWhole {
    final buffer = StringBuffer();
    for (var i = 0; i < _whole.length; i++) {
      final fromEnd = _whole.length - i;
      if (i > 0 && fromEnd % 3 == 0) buffer.write(' ');
      buffer.write(_whole[i]);
    }
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    final enteredAmount = _decimal == null
        ? _groupedWhole
        : '$_groupedWhole.${_decimal!}';
    final decimalPlaceholder = _decimal == null
        ? '.00'
        : ''.padRight(2 - _decimal!.length, '0');
    final accounts = ref.watch(accountsProvider).value ?? const [];
    final accountLabel = accounts.isEmpty
        ? 'No account yet'
        : accounts.first.name;

    return GradientBackground(
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: Row(
                  children: [
                    GlassBackButton(onPressed: _goBack),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Text(
                        'New transaction',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.75),
                        borderRadius: BorderRadius.circular(99),
                        border: Border.all(
                          color: AppColors.white.withValues(alpha: 0.9),
                        ),
                      ),
                      child: const Text(
                        'Step 1 of 2',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 14, 20, 0),
                child: ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(99)),
                  child: LinearProgressIndicator(
                    value: 0.5,
                    minHeight: 4,
                    backgroundColor: AppColors.dotInactive,
                    valueColor: AlwaysStoppedAnimation(AppColors.accentBlue),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                child: _KindSelector(
                  kind: _kind,
                  onChanged: (kind) => setState(() => _kind = kind),
                ),
              ),
              if (_kind == TransactionKind.expense) ...[
                const SizedBox(height: 14),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: PillButton(
                    label: _scanningReceipt ? 'Scanning…' : 'Scan a receipt',
                    leading: _scanningReceipt
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.accentBlue,
                            ),
                          )
                        : const Icon(
                            Icons.camera_alt_outlined,
                            size: 18,
                            color: AppColors.accentBlue,
                          ),
                    onPressed: _scanningReceipt ? null : _scanReceipt,
                    backgroundColor: AppColors.white,
                    foregroundColor: AppColors.accentBlue,
                    borderColor: AppColors.white,
                  ),
                ),
                if (_scanError != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                    child: Text(
                      _scanError!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.error,
                        fontSize: 12.5,
                      ),
                    ),
                  ),
              ],
              const SizedBox(height: 34),
              const Text(
                'AMOUNT',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.labelGray,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text('${_kind.sign}₴ ', style: _amountWholeStyle),
                  _AmountEditableText(text: enteredAmount),
                  Text(decimalPlaceholder, style: _amountDecimalStyle),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.75),
                  borderRadius: BorderRadius.circular(99),
                  border: Border.all(
                    color: AppColors.white.withValues(alpha: 0.9),
                  ),
                ),
                child: Text(
                  'UAH · $accountLabel',
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.grayText,
                  ),
                ),
              ),
              const SizedBox(height: 36),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                child: _Keypad(
                  onDigit: _pressDigit,
                  onComma: _pressComma,
                  onBackspace: _pressBackspace,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                child: PillButton(
                  label: 'Next · details',
                  onPressed: _hasAmount && accounts.isNotEmpty ? _next : null,
                  backgroundColor: AppColors.accentBlueMuted,
                  foregroundColor: AppColors.white,
                  borderColor: AppColors.accentBlueMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

const _amountWholeStyle = TextStyle(
  fontSize: 34,
  fontWeight: FontWeight.w800,
  color: AppColors.textDark,
);

const _amountDecimalStyle = TextStyle(
  fontSize: 34,
  fontWeight: FontWeight.w700,
  color: AppColors.balanceCentsText,
);

class _AmountEditableText extends StatefulWidget {
  const _AmountEditableText({required this.text});

  final String text;

  @override
  State<_AmountEditableText> createState() => _AmountEditableTextState();
}

class _AmountEditableTextState extends State<_AmountEditableText> {
  late final _controller = _AmountTextController(widget.text);
  final _focusNode = FocusNode();

  @override
  void didUpdateWidget(covariant _AmountEditableText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.text != oldWidget.text) {
      _controller.value = TextEditingValue(
        text: widget.text,
        selection: TextSelection.collapsed(offset: widget.text.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textPainter = TextPainter(
      text: _controller.buildTextSpan(
        context: context,
        style: _amountWholeStyle,
        withComposing: false,
      ),
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
      maxLines: 1,
    )..layout();

    return SizedBox(
      width: textPainter.width + 6,
      height: textPainter.height,
      child: EditableText(
        controller: _controller,
        focusNode: _focusNode,
        autofocus: true,
        readOnly: true,
        showCursor: true,
        rendererIgnoresPointer: true,
        enableInteractiveSelection: false,
        style: _amountWholeStyle,
        cursorColor: AppColors.accentBlue,
        backgroundCursorColor: AppColors.grayText,
        cursorWidth: 2,
        cursorHeight: 30,
        cursorRadius: const Radius.circular(99),
        cursorOpacityAnimates: true,
        selectionColor: AppColors.transparent,
        maxLines: 1,
      ),
    );
  }
}

class _AmountTextController extends TextEditingController {
  _AmountTextController(String text) : super(text: text) {
    selection = TextSelection.collapsed(offset: text.length);
  }

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final decimalIndex = text.indexOf('.');
    if (decimalIndex == -1) {
      return TextSpan(text: text, style: _amountWholeStyle);
    }
    return TextSpan(
      children: [
        TextSpan(
          text: text.substring(0, decimalIndex),
          style: _amountWholeStyle,
        ),
        TextSpan(
          text: text.substring(decimalIndex),
          style: _amountDecimalStyle,
        ),
      ],
    );
  }
}

class _KindSelector extends StatelessWidget {
  const _KindSelector({required this.kind, required this.onChanged});

  final TransactionKind kind;
  final ValueChanged<TransactionKind> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: AppColors.white.withValues(alpha: 0.7)),
      ),
      child: Row(
        children: [
          for (final option in TransactionKind.values)
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(option),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: kind == option
                        ? AppColors.white
                        : AppColors.transparent,
                    borderRadius: BorderRadius.circular(99),
                    boxShadow: kind == option
                        ? [
                            BoxShadow(
                              color: AppColors.shadowBlue.withValues(
                                alpha: 0.16,
                              ),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    option.label,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: kind == option
                          ? AppColors.textDark
                          : AppColors.grayText,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Keypad extends StatelessWidget {
  const _Keypad({
    required this.onDigit,
    required this.onComma,
    required this.onBackspace,
  });

  final ValueChanged<String> onDigit;
  final VoidCallback onComma;
  final VoidCallback onBackspace;

  static const _rows = [
    ['1', '2', '3'],
    ['4', '5', '6'],
    ['7', '8', '9'],
    [',', '0', '⌫'],
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final row in _rows) ...[
          Row(
            children: [
              for (final key in row) ...[
                if (key != row.first) const SizedBox(width: 10),
                Expanded(
                  child: _KeypadKey(label: key, onTap: () => _onKey(key)),
                ),
              ],
            ],
          ),
          if (row != _rows.last) const SizedBox(height: 10),
        ],
      ],
    );
  }

  void _onKey(String key) {
    switch (key) {
      case ',':
        onComma();
      case '⌫':
        onBackspace();
      default:
        onDigit(key);
    }
  }
}

class _KeypadKey extends StatelessWidget {
  const _KeypadKey({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.transparent,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          child: Container(
            height: 58,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.white.withValues(alpha: 0.7)),
            ),
            child: label == '⌫'
                ? const Icon(
                    Icons.backspace_outlined,
                    size: 20,
                    color: AppColors.textDark,
                  )
                : Text(
                    label,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
