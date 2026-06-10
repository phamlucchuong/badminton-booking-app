import '/components/button/button_widget.dart';
import '/components/profile_menu_item/profile_menu_item_widget.dart';
import '/components/section_header/section_header_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'user_profile_model.dart';
export 'user_profile_model.dart';
import 'package:app_user/main.dart';

class UserProfileWidget extends StatefulWidget {
  const UserProfileWidget({super.key});

  static String routeName = 'UserProfile';
  static String routePath = '/userProfile';

  @override
  State<UserProfileWidget> createState() => _UserProfileWidgetState();
}

class _UserProfileWidgetState extends State<UserProfileWidget> {
  late UserProfileModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  String _userName = 'John Doe';
  String _userEmail = 'john.doe@example.com';
  String _userPhone = '+84 987 654 321';
  String _userAddress = 'Ho Chi Minh City';

  String _getInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts[0].isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
  }

  void _showEditDialog(
      String title, String currentValue, Function(String) onSave) {
    final controller = TextEditingController(text: currentValue);
    final localizedField = () {
      switch (title) {
        case 'Name': return context.l10n('Name', 'Họ tên');
        case 'Phone Number': return context.l10n('Phone Number', 'Số điện thoại');
        case 'Email Address': return context.l10n('Email Address', 'Địa chỉ email');
        case 'Address': return context.l10n('Address', 'Địa chỉ');
        case 'Password': return context.l10n('Password', 'Mật khẩu');
        default: return title;
      }
    }();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(context.l10n('Edit $title', 'Chỉnh sửa $localizedField'),
              style: FlutterFlowTheme.of(context).titleMedium),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: context.l10n('Enter new $title', 'Nhập $localizedField mới'),
              focusedBorder: UnderlineInputBorder(
                borderSide:
                    BorderSide(color: FlutterFlowTheme.of(context).primary),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(context.l10n('Cancel', 'Hủy'),
                  style: TextStyle(
                      color: FlutterFlowTheme.of(context).secondaryText)),
            ),
            TextButton(
              onPressed: () {
                onSave(controller.text);
                Navigator.pop(context);
              },
              child: Text(context.l10n('Save', 'Lưu'),
                  style:
                      TextStyle(color: FlutterFlowTheme.of(context).primary)),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => UserProfileModel());
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: SafeArea(
          top: true,
          child: SingleChildScrollView(
            primary: false,
            child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).secondaryBackground,
                  shape: BoxShape.rectangle,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(
                          24.0, 16.0, 24.0, 16.0),
                      child: Container(
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                FlutterFlowIconButton(
                                  borderRadius: 8.0,
                                  buttonSize: 40.0,
                                  fillColor: Colors.transparent,
                                  icon: Icon(
                                    Icons.arrow_back_rounded,
                                    color: FlutterFlowTheme.of(context)
                                        .primaryText,
                                    size: 24.0,
                                  ),
                                  onPressed: () async {
                                    context.pop();
                                  },
                                ),
                                Text(
                                  context.l10n('My Account', 'Tài khoản của tôi'),
                                  style: FlutterFlowTheme.of(context)
                                      .titleMedium
                                      .override(
                                        font: GoogleFonts.plusJakartaSans(
                                          fontWeight: FontWeight.w600,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .titleMedium
                                                  .fontStyle,
                                        ),
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.w600,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .titleMedium
                                            .fontStyle,
                                        lineHeight: 1.4,
                                      ),
                                ),
                              ].divide(SizedBox(width: 16.0)),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                InkWell(
                                  splashColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () async {
                                    FFAppState().language =
                                        FFAppState().language == 'EN'
                                            ? 'VI'
                                            : 'EN';
                                    FFAppState().update(() {});
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: FlutterFlowTheme.of(context)
                                          .primaryContainer,
                                      borderRadius:
                                          BorderRadius.circular(9999.0),
                                      shape: BoxShape.rectangle,
                                    ),
                                    child: Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          16.0, 8.0, 16.0, 8.0),
                                      child: Container(
                                        child: Text(
                                          FFAppState().language,
                                          style: FlutterFlowTheme.of(context)
                                              .labelSmall
                                              .override(
                                                font: GoogleFonts.inter(
                                                  fontWeight: FontWeight.bold,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .labelSmall
                                                          .fontStyle,
                                                ),
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .onPrimaryContainer,
                                                letterSpacing: 0.0,
                                                fontWeight: FontWeight.bold,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .labelSmall
                                                        .fontStyle,
                                                lineHeight: 1.3,
                                              ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                FlutterFlowIconButton(
                                  borderRadius: 8.0,
                                  buttonSize: 40.0,
                                  fillColor: Colors.transparent,
                                  icon: Icon(
                                    FFAppState().darkMode
                                        ? Icons.wb_sunny_rounded
                                        : Icons.nights_stay_rounded,
                                    color: FlutterFlowTheme.of(context)
                                        .primaryText,
                                    size: 24.0,
                                  ),
                                  onPressed: () async {
                                    final newMode = !FFAppState().darkMode;
                                    FFAppState().darkMode = newMode;
                                    FFAppState().update(() {});
                                    MyApp.of(context).setThemeMode(
                                        newMode ? ThemeMode.dark : ThemeMode.light);
                                  },
                                ),
                              ].divide(SizedBox(width: 8.0)),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      height: 1.0,
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).alternate,
                        shape: BoxShape.rectangle,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).secondaryBackground,
                  shape: BoxShape.rectangle,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(
                          24.0, 32.0, 24.0, 32.0),
                      child: Container(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Stack(
                              alignment: AlignmentDirectional(0.0, 0.0),
                              children: [
                                Container(
                                  width: 100.0,
                                  height: 100.0,
                                  decoration: BoxDecoration(
                                    color: FlutterFlowTheme.of(context).primary,
                                    shape: BoxShape.circle,
                                  ),
                                  alignment: AlignmentDirectional(0.0, 0.0),
                                  child: Text(
                                    _getInitials(_userName),
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    style: FlutterFlowTheme.of(context)
                                        .labelMedium
                                        .override(
                                          font: GoogleFonts.inter(
                                            fontWeight: FontWeight.w600,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .labelMedium
                                                    .fontStyle,
                                          ),
                                          color: FlutterFlowTheme.of(context)
                                              .onPrimary,
                                          fontSize: 38.0,
                                          letterSpacing: 0.0,
                                          fontWeight: FontWeight.w600,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .labelMedium
                                                  .fontStyle,
                                          lineHeight: 1.3,
                                        ),
                                    overflow: TextOverflow.clip,
                                  ),
                                ),
                                Align(
                                  alignment: AlignmentDirectional(1.0, 1.0),
                                  child: InkWell(
                                    onTap: () {
                                      _showEditDialog('Name', _userName, (val) {
                                        safeSetState(() {
                                          _userName = val;
                                        });
                                      });
                                    },
                                    child: Container(
                                      width: 32.0,
                                      height: 32.0,
                                      decoration: BoxDecoration(
                                        color: FlutterFlowTheme.of(context)
                                            .tertiary,
                                        borderRadius:
                                            BorderRadius.circular(9999.0),
                                        shape: BoxShape.rectangle,
                                        border: Border.all(
                                          color: FlutterFlowTheme.of(context)
                                              .secondaryBackground,
                                          width: 2.0,
                                        ),
                                      ),
                                      alignment: AlignmentDirectional(0.0, 0.0),
                                      child: Icon(
                                        Icons.edit_rounded,
                                        color: FlutterFlowTheme.of(context)
                                            .onAccent,
                                        size: 16.0,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  _userName,
                                  style: FlutterFlowTheme.of(context)
                                      .headlineMedium
                                      .override(
                                        font: GoogleFonts.plusJakartaSans(
                                          fontWeight: FontWeight.bold,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .headlineMedium
                                                  .fontStyle,
                                        ),
                                        color: FlutterFlowTheme.of(context)
                                            .primaryText,
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.bold,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .headlineMedium
                                            .fontStyle,
                                        lineHeight: 1.25,
                                      ),
                                ),
                                Text(
                                  _userEmail,
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        font: GoogleFonts.inter(
                                          fontWeight:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontWeight,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontStyle,
                                        ),
                                        color: FlutterFlowTheme.of(context)
                                            .secondaryText,
                                        letterSpacing: 0.0,
                                        fontWeight: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontStyle,
                                        lineHeight: 1.5,
                                      ),
                                ),
                              ].divide(SizedBox(height: 4.0)),
                            ),
                            Container(
                              height: 8.0,
                            ),
                            InkWell(
                              onTap: () {
                                _showEditDialog('Name', _userName, (val) {
                                  safeSetState(() {
                                    _userName = val;
                                  });
                                });
                              },
                              child: wrapWithModel(
                                model: _model.buttonModel1,
                                updateCallback: () => safeSetState(() {}),
                                child: ButtonWidget(
                                  content: context.l10n('Edit Profile', 'Sửa hồ sơ'),
                                  iconPresent: false,
                                  iconEndPresent: false,
                                  variant: 'outline',
                                  size: 'small',
                                  fullWidth: false,
                                  loading: false,
                                  disabled: false,
                                ),
                              ),
                            ),
                          ].divide(SizedBox(height: 16.0)),
                        ),
                      ),
                    ),
                    Container(
                      height: 1.0,
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).alternate,
                        shape: BoxShape.rectangle,
                      ),
                    ),
                  ],
                ),
              ),
              wrapWithModel(
                model: _model.sectionHeaderModel1,
                updateCallback: () => safeSetState(() {}),
                child: SectionHeaderWidget(
                  title: context.l10n('PERSONAL INFORMATION', 'THÔNG TIN CÁ NHÂN'),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  InkWell(
                    onTap: () {
                      _showEditDialog('Phone Number', _userPhone, (val) {
                        safeSetState(() {
                          _userPhone = val;
                        });
                      });
                    },
                    child: wrapWithModel(
                      model: _model.profileMenuItemModel1,
                      updateCallback: () => safeSetState(() {}),
                      child: ProfileMenuItemWidget(
                        bgColor: FlutterFlowTheme.of(context).info10,
                        icon: Icon(
                          Icons.phone_android_rounded,
                          color: FlutterFlowTheme.of(context).info,
                          size: 22.0,
                        ),
                        iconColor: FlutterFlowTheme.of(context).info,
                        title: context.l10n('Phone Number', 'Số điện thoại'),
                        subtitle: _userPhone,
                        hasSubtitle: true,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      _showEditDialog('Email Address', _userEmail, (val) {
                        safeSetState(() {
                          _userEmail = val;
                        });
                      });
                    },
                    child: wrapWithModel(
                      model: _model.profileMenuItemModel2,
                      updateCallback: () => safeSetState(() {}),
                      child: ProfileMenuItemWidget(
                        bgColor: FlutterFlowTheme.of(context).success10,
                        icon: Icon(
                          Icons.mail_outline_rounded,
                          color: FlutterFlowTheme.of(context).success,
                          size: 22.0,
                        ),
                        iconColor: FlutterFlowTheme.of(context).success,
                        title: context.l10n('Email Address', 'Địa chỉ email'),
                        subtitle: _userEmail,
                        hasSubtitle: true,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      _showEditDialog('Address', _userAddress, (val) {
                        safeSetState(() {
                          _userAddress = val;
                        });
                      });
                    },
                    child: wrapWithModel(
                      model: _model.profileMenuItemModel3,
                      updateCallback: () => safeSetState(() {}),
                      child: ProfileMenuItemWidget(
                        bgColor: FlutterFlowTheme.of(context).warning10,
                        icon: Icon(
                          Icons.location_on_outlined,
                          color: FlutterFlowTheme.of(context).warning,
                          size: 22.0,
                        ),
                        iconColor: FlutterFlowTheme.of(context).warning,
                        title: context.l10n('My Addresses', 'Địa chỉ của tôi'),
                        subtitle: _userAddress == 'Ho Chi Minh City' ? context.l10n('Ho Chi Minh City', 'Thành phố Hồ Chí Minh') : _userAddress,
                        hasSubtitle: true,
                      ),
                    ),
                  ),
                ],
              ),
              wrapWithModel(
                model: _model.sectionHeaderModel2,
                updateCallback: () => safeSetState(() {}),
                child: SectionHeaderWidget(
                  title: context.l10n('SECURITY & PREFERENCES', 'BẢO MẬT & TÙY CHỌN'),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  InkWell(
                    onTap: () {
                      _showEditDialog('Password', '', (val) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(context.l10n('Password updated successfully!', 'Cập nhật mật khẩu thành công!')),
                          ),
                        );
                      });
                    },
                    child: wrapWithModel(
                      model: _model.profileMenuItemModel4,
                      updateCallback: () => safeSetState(() {}),
                      child: ProfileMenuItemWidget(
                        bgColor: FlutterFlowTheme.of(context).primary10,
                        icon: Icon(
                          Icons.lock_outline_rounded,
                          color: FlutterFlowTheme.of(context).primary,
                          size: 22.0,
                        ),
                        iconColor: FlutterFlowTheme.of(context).primary,
                        title: context.l10n('Change Password', 'Đổi mật khẩu'),
                        subtitle: '',
                        hasSubtitle: false,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(context.l10n('Notifications settings updated!', 'Cập nhật cài đặt thông báo thành công!')),
                        ),
                      );
                    },
                    child: wrapWithModel(
                      model: _model.profileMenuItemModel5,
                      updateCallback: () => safeSetState(() {}),
                      child: ProfileMenuItemWidget(
                        bgColor: FlutterFlowTheme.of(context).primary10,
                        icon: Icon(
                          Icons.notifications_none_rounded,
                          color: FlutterFlowTheme.of(context).primary,
                          size: 22.0,
                        ),
                        iconColor: FlutterFlowTheme.of(context).primary,
                        title: context.l10n('Push Notifications', 'Thông báo đẩy'),
                        subtitle: '',
                        hasSubtitle: false,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(context.l10n('Privacy settings updated!', 'Cập nhật cài đặt riêng tư thành công!')),
                        ),
                      );
                    },
                    child: wrapWithModel(
                      model: _model.profileMenuItemModel6,
                      updateCallback: () => safeSetState(() {}),
                      child: ProfileMenuItemWidget(
                        bgColor: FlutterFlowTheme.of(context).success10,
                        icon: Icon(
                          Icons.verified_user_outlined,
                          color: FlutterFlowTheme.of(context).success,
                          size: 22.0,
                        ),
                        iconColor: FlutterFlowTheme.of(context).success,
                        title: context.l10n('Privacy Settings', 'Cài đặt riêng tư'),
                        subtitle: '',
                        hasSubtitle: false,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () async {
                      final newMode = !FFAppState().darkMode;
                      FFAppState().darkMode = newMode;
                      FFAppState().update(() {});
                      MyApp.of(context).setThemeMode(
                          newMode ? ThemeMode.dark : ThemeMode.light);
                    },
                    child: wrapWithModel(
                      model: _model.profileMenuItemModel9,
                      updateCallback: () => safeSetState(() {}),
                      child: ProfileMenuItemWidget(
                        bgColor: FlutterFlowTheme.of(context).warning10,
                        icon: Icon(
                          FFAppState().darkMode
                              ? Icons.wb_sunny_rounded
                              : Icons.nights_stay_rounded,
                          color: FlutterFlowTheme.of(context).warning,
                          size: 22.0,
                        ),
                        iconColor: FlutterFlowTheme.of(context).warning,
                        title: context.l10n('Dark Mode', 'Chế độ tối'),
                        subtitle: FFAppState().darkMode
                            ? context.l10n('On', 'Bật')
                            : context.l10n('Off', 'Tắt'),
                        hasSubtitle: true,
                      ),
                    ),
                  ),
                ],
              ),
              wrapWithModel(
                model: _model.sectionHeaderModel3,
                updateCallback: () => safeSetState(() {}),
                child: SectionHeaderWidget(
                  title: context.l10n('SUPPORT', 'HỖ TRỢ'),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  wrapWithModel(
                    model: _model.profileMenuItemModel7,
                    updateCallback: () => safeSetState(() {}),
                    child: ProfileMenuItemWidget(
                      bgColor: FlutterFlowTheme.of(context).secondaryText10,
                      icon: Icon(
                        Icons.help_outline_rounded,
                        color: FlutterFlowTheme.of(context).secondaryText,
                        size: 22.0,
                      ),
                      iconColor: FlutterFlowTheme.of(context).secondaryText,
                      title: context.l10n('Help Center', 'Trung tâm trợ giúp'),
                      subtitle: '',
                      hasSubtitle: false,
                    ),
                  ),
                  wrapWithModel(
                    model: _model.profileMenuItemModel8,
                    updateCallback: () => safeSetState(() {}),
                    child: ProfileMenuItemWidget(
                      bgColor: FlutterFlowTheme.of(context).secondaryText10,
                      icon: Icon(
                        Icons.info_outlined,
                        color: FlutterFlowTheme.of(context).secondaryText,
                        size: 22.0,
                      ),
                      iconColor: FlutterFlowTheme.of(context).secondaryText,
                      title: context.l10n('Terms & Conditions', 'Điều khoản & Điều kiện'),
                      subtitle: '',
                      hasSubtitle: false,
                    ),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 32.0),
                child: Container(
                  child: Container(
                    child: Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(
                          24.0, 32.0, 24.0, 32.0),
                      child: Container(
                        child: InkWell(
                          splashColor: Colors.transparent,
                          focusColor: Colors.transparent,
                          hoverColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onTap: () async {
                            // Clear token store locally first to ensure instant logout
                            FFAppState().authRepository.logout().catchError((_) {});
                            await FFAppState().tokenStore.clear();
                            FFAppState().update(
                                () => FFAppState().isLoggedIn = false);
                            if (context.mounted) {
                              context.goNamed(AuthenticationWidget.routeName);
                            }
                          },
                          child: wrapWithModel(
                            model: _model.buttonModel2,
                            updateCallback: () => safeSetState(() {}),
                            child: ButtonWidget(
                              content: context.l10n('Log Out', 'Đăng xuất'),
                              icon: Icon(
                                Icons.logout_rounded,
                                color: FlutterFlowTheme.of(context).onError,
                                size: 16.0,
                              ),
                              iconPresent: true,
                              iconEndPresent: false,
                              variant: 'destructive',
                              size: 'medium',
                              fullWidth: true,
                              loading: false,
                              disabled: false,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Container(
                    child: Container(
                      alignment: AlignmentDirectional(0.0, 0.0),
                      child: Text(
                        'CourtDash v2.4.0',
                        style: FlutterFlowTheme.of(context).labelSmall.override(
                              font: GoogleFonts.inter(
                                fontWeight: FlutterFlowTheme.of(context)
                                    .labelSmall
                                    .fontWeight,
                                fontStyle: FlutterFlowTheme.of(context)
                                    .labelSmall
                                    .fontStyle,
                              ),
                              color: FlutterFlowTheme.of(context).accent3,
                              letterSpacing: 0.0,
                              fontWeight: FlutterFlowTheme.of(context)
                                  .labelSmall
                                  .fontWeight,
                              fontStyle: FlutterFlowTheme.of(context)
                                  .labelSmall
                                  .fontStyle,
                              lineHeight: 1.3,
                            ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
    );
  }
}
