import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:piktlab/constants/app_colors.dart';
import 'package:piktlab/constants/ui_constants.dart';
import 'package:piktlab/pikt/color_scheme.dart';
import 'package:piktlab/tools/tools.dart';
import 'package:piktlab/ui/utils/overlay.dart';

class ToolbarColorPicker extends StatefulWidget {
  const ToolbarColorPicker({Key? key}) : super(key: key);

  @override
  _ToolbarColorPickerState createState() => _ToolbarColorPickerState();
}

class _ToolbarColorPickerState extends State<ToolbarColorPicker> {
  Color _color = currentColor;

  @override
  void initState() {
    addColorListener((color) {
      setState(() {
        _color = color;
      });
    });
    super.initState();
  }

  _buildFloatingPickerPopup() {
    final picker = ColorPickerOverlay(
      initialColor: _color,
      onColorChanged: (color) {
        setState(() {
          _color = color;
        });
        currentColor = color;
      },
    );
    return CloseableOverlay().buildOverlay(
      context,
      child: picker,
      offset: const Offset(UIConstants.color_picker_offset_x, 0),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.passthrough,
      children: [
        RawMaterialButton(
          fillColor: _color,
          shape: const CircleBorder(),
          child: Container(
            width: UIConstants.toolbar_color_picker_size,
            height: UIConstants.toolbar_color_picker_size,
            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppColors.toolbar_color_picker_border, width: UIConstants.toolbar_color_picker_border_width)),
          ),
          onPressed: () {
            Overlay.of(context)?.insert(_buildFloatingPickerPopup());
          },
        ),
      ],
    );
  }
}

/// Pop-up over the color picker toolbar button.
class ColorPickerOverlay extends StatefulWidget {
  final Color initialColor;
  final ValueChanged<Color> onColorChanged;

  const ColorPickerOverlay({Key? key, required this.initialColor, required this.onColorChanged}) : super(key: key);

  @override
  _ColorPickerOverlayState createState() => _ColorPickerOverlayState();
}

class _ColorPickerOverlayState extends State<ColorPickerOverlay> {
  Color? _color;
  HSVColor? _hsvColor;

  final FocusNode _focus = FocusNode();
  TextEditingController? _hexController;
  String? _lastValidHex; // Takes _hexController value only if its length is either 6 or 7.

  _setColor(Color value, [HSVColor? hsvColor]) {
    _setColorWithoutTextfieldUpdate(value, hsvColor);
    _hexController?.text = value.hex;
  }

  _setColorWithoutTextfieldUpdate(Color value, [HSVColor? hsvColor]) {
    setState(() {
      _color = value;
      _hsvColor = hsvColor ?? HSVColor.fromColor(value);
    });
    currentTool = Pencil();
    widget.onColorChanged(value);
  }

  @override
  void initState() {
    _color = widget.initialColor;
    _hsvColor = HSVColor.fromColor(_color!);
    _lastValidHex = widget.initialColor.hex;
    _initHexController();
    super.initState();
  }

  _initHexController() {
    _hexController = TextEditingController(text: _color!.hex)
      ..addListener(() {
        if (_hexController!.text != _color!.hex) {
          if(_hexController!.text.length == 6 || _hexController!.text.length == 7) {
            _lastValidHex = _hexController!.text;
          }
          _setColorWithoutTextfieldUpdate(HexColor.fromHex(_lastValidHex!));
        }
      });
  }

  TextStyle get _textStyle => const TextStyle(
        color: AppColors.color_picker_text,
      );

  _buildPickerArea() => SizedBox(
        width: UIConstants.color_picker_area_size,
        height: UIConstants.color_picker_area_size,
        child: ColorPickerArea(
          _hsvColor!,
          (color) {
            FocusScope.of(context).unfocus();
            _setColor(color.toColor(), color);
          },
          PaletteType.hsv,
        ),
      );

  _buildSlider() => SizedBox(
    width: UIConstants.color_picker_slider_width,
    height: UIConstants.color_picker_area_size + UIConstants.color_picker_slider_height,
    child: RotatedBox(
      quarterTurns: -1,
      child: ColorPickerSlider(
        TrackType.hue,
        _hsvColor!,
        (color) {
          FocusScope.of(context).unfocus();
          _setColor(color.toColor(), color);
        },
        fullThumbColor: true,
        displayThumbColor: true,
      ),
    ),
  );

  _buildHexField() {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(UIConstants.color_picker_hex_border_radius),
      borderSide: BorderSide(
        color: AppColors.color_picker_text.withOpacity(UIConstants.color_picker_hex_border_opacity),
        width: UIConstants.color_picker_hex_border_width,
      ),
    );
    return TextField(
      controller: _hexController,
      focusNode: _focus,
      style: _textStyle.copyWith(fontSize: UIConstants.color_picker_hex_font_size),
      cursorColor: AppColors.color_picker_text,
      cursorWidth: UIConstants.color_picker_hex_cursor_width,
      decoration: InputDecoration(
        border: border,
        enabledBorder: border,
        focusedBorder: border,
      ),
      onSubmitted: (text) => closeOverlays(context),
    );
  }

  _buildHex() {
    return Row(
      children: [
        Text(
          '#  ',
          style: _textStyle.copyWith(
            fontSize: UIConstants.color_picker_hex_font_size,
            height: 0,
            color: AppColors.color_picker_text.withOpacity(
              UIConstants.color_picker_hex_prefix_opacity,
            ),
          ),
        ),
        Column(
          children: [
            SizedBox(
              width: UIConstants.color_picker_hex_width,
              child: _buildHexField(),
            ),
            const SizedBox(height: UIConstants.color_picker_preview_height),
            Container(
              width: UIConstants.color_picker_preview_width,
              height: UIConstants.color_picker_preview_height,
              decoration: BoxDecoration(
                color: _color,
                borderRadius: BorderRadius.circular(32),
              ),
            ),
          ],
        )
      ],
    );
  }

  _buildRGBValues() {
    final style = _textStyle.copyWith(fontSize: UIConstants.color_picker_rgb_font_size, height: 1.3);
    _buildPair(String first, Object second) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: UIConstants.color_picker_rgb_width,
            child: Text(
              first,
              style: style.copyWith(color: AppColors.color_picker_text.withOpacity(UIConstants.color_picker_rgb_opacity)),
            ),
          ),
          Text(second.toString(), style: style),
        ],
      );
    }

    return [
      _buildPair('R', _color?.red ?? 0),
      _buildPair('G', _color?.green ?? 0),
      _buildPair('B', _color?.blue ?? 0),
    ];
  }

  _buildRGBPicker() => Row(
        children: [
          _buildPickerArea(),
          _buildSlider(),
          const SizedBox(width: UIConstants.color_picker_horizontal_spacing),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHex(),
              const Spacer(),
              ..._buildRGBValues(),
            ],
          ),
        ],
      );

  @override
  Widget build(BuildContext context) {
    FocusScope.of(context).requestFocus(_focus);
    return Material(
      color: Colors.transparent,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(UIConstants.color_picker_radius),
        child: SizedBox(
          height: UIConstants.color_picker_area_size + UIConstants.color_picker_slider_height * 2,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: UIConstants.color_picker_blur, sigmaY: UIConstants.color_picker_blur),
            child: Container(
              padding: const EdgeInsets.all(UIConstants.color_picker_padding),
              color: AppColors.color_picker,
              child: _buildRGBPicker(),
            ),
          ),
        ),
      ),
    );
  }
}
