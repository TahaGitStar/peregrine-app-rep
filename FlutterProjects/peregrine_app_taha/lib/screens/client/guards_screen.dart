import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:peregrine_app_taha/models/guard_models.dart';
import 'package:peregrine_app_taha/screens/client/guard_details_screen.dart';
import 'package:peregrine_app_taha/services/guard_service.dart';
import 'package:peregrine_app_taha/utils/app_theme.dart';
import 'package:peregrine_app_taha/utils/date_formatter.dart';
import 'package:peregrine_app_taha/widgets/error_widget.dart';
import 'package:peregrine_app_taha/widgets/loading_widget.dart';

class GuardsScreen extends StatefulWidget {
  static const String routeName = '/client-guards';
  
  const GuardsScreen({super.key});

  @override
  State<GuardsScreen> createState() => _GuardsScreenState();
}

class _GuardsScreenState extends State<GuardsScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  bool _isLoading = true;
  String? _errorMessage;
  List<Guard> _guards = [];
  
  @override
  void initState() {
    super.initState();
    
    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    
    // Load guards data
    _loadGuards();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  /// Load guards data from the service
  Future<void> _loadGuards() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final response = await GuardService.getAssignedGuards();
      
      if (response.success) {
        setState(() {
          _guards = response.guards;
          _isLoading = false;
        });
        _animationController.forward();
      } else {
        setState(() {
          _errorMessage = response.message;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'حدث خطأ أثناء تحميل البيانات';
        _isLoading = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        title: Text(
          'أفرادي',
          style: GoogleFonts.cairo(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        elevation: 8,
        shadowColor: AppTheme.primary.withOpacity(0.5),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        actions: [
          // Refresh button
          IconButton(
            icon: const Icon(LucideIcons.refreshCw, color: Colors.white, size: 22),
            splashRadius: 24,
            tooltip: 'تحديث',
            onPressed: () {
              HapticFeedback.mediumImpact();
              _loadGuards();
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _buildBody(),
    );
  }
  
  Widget _buildBody() {
    if (_isLoading) {
      return const LoadingWidget(message: 'جاري تحميل بيانات الحراس...');
    }
    
    if (_errorMessage != null) {
      return AppErrorWidget(
        message: _errorMessage!,
        onRetry: _loadGuards,
      );
    }
    
    if (_guards.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.userX,
              size: 64,
              color: AppTheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'لا يوجد حراس مخصصين لك',
              style: GoogleFonts.cairo(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.accent,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'سيظهر هنا قائمة الحراس المخصصين لك',
              style: GoogleFonts.cairo(
                fontSize: 14,
                color: AppTheme.accent.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadGuards,
              icon: const Icon(LucideIcons.refreshCw, size: 18),
              label: Text(
                'تحديث',
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ),
      );
    }
    
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: child,
        );
      },
      child: RefreshIndicator(
        onRefresh: _loadGuards,
        color: AppTheme.primary,
        backgroundColor: Colors.white,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _guards.length,
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          itemBuilder: (context, index) {
            final guard = _guards[index];
            // Staggered animation for list items
            return AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                final delay = (index * 0.1).clamp(0.0, 0.5);
                final itemAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
                  CurvedAnimation(
                    parent: _animationController,
                    curve: Interval(delay, delay + 0.4, curve: Curves.easeOutQuart),
                  ),
                );
                
                return FadeTransition(
                  opacity: itemAnimation,
                  child: Transform.translate(
                    offset: Offset(0, 20 * (1 - itemAnimation.value)),
                    child: child,
                  ),
                );
              },
              child: _buildGuardCard(guard),
            );
          },
        ),
      ),
    );
  }
  
  Widget _buildGuardCard(Guard guard) {
    // Check if guard is on leave
    final onLeave = guard.leaveDays.any((leave) => leave.isActive);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shadowColor: AppTheme.primary.withOpacity(0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: onLeave 
              ? Colors.orange.withOpacity(0.5) 
              : AppTheme.primary.withOpacity(0.1),
          width: onLeave ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GuardDetailsScreen(guardId: guard.id),
            ),
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Guard avatar
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: onLeave 
                            ? Colors.orange 
                            : AppTheme.primary,
                        width: 2,
                      ),
                    ),
                    child: guard.profileImageUrl != null
                        ? ClipOval(
                            child: Image.network(
                              guard.profileImageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(
                                  LucideIcons.user,
                                  color: AppTheme.primary,
                                  size: 30,
                                );
                              },
                            ),
                          )
                        : const Icon(
                            LucideIcons.user,
                            color: AppTheme.primary,
                            size: 30,
                          ),
                  ),
                  const SizedBox(width: 16),
                  
                  // Guard info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                guard.name,
                                style: GoogleFonts.cairo(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.accent,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (onLeave)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.orange,
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  'في إجازة',
                                  style: GoogleFonts.cairo(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'رقم الشارة: ${guard.badgeNumber}',
                          style: GoogleFonts.cairo(
                            fontSize: 14,
                            color: AppTheme.accent.withOpacity(0.7),
                          ),
                        ),
                        if (guard.specialization != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            guard.specialization!,
                            style: GoogleFonts.cairo(
                              fontSize: 14,
                              color: AppTheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              
              // Schedule preview
              Text(
                'جدول العمل:',
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.accent,
                ),
              ),
              const SizedBox(height: 8),
              
              // Show first 3 days of schedule
              ...guard.schedule.take(3).map((schedule) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        schedule.dayName,
                        style: GoogleFonts.cairo(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${schedule.startTime} - ${schedule.endTime}',
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        color: AppTheme.accent,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      schedule.location,
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        color: AppTheme.accent.withOpacity(0.7),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              )),
              
              if (guard.schedule.length > 3) ...[
                const SizedBox(height: 4),
                Center(
                  child: Text(
                    '+ ${guard.schedule.length - 3} أيام أخرى',
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
              
              // Show replacement guard if on leave
              if (onLeave && guard.leaveDays.first.replacementGuard != null) ...[
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                
                Row(
                  children: [
                    const Icon(
                      LucideIcons.userCheck,
                      color: Colors.green,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'الحارس البديل:',
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.accent,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                
                Row(
                  children: [
                    // Replacement guard avatar
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.green,
                          width: 2,
                        ),
                      ),
                      child: guard.leaveDays.first.replacementGuard!.profileImageUrl != null
                          ? ClipOval(
                              child: Image.network(
                                guard.leaveDays.first.replacementGuard!.profileImageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(
                                    LucideIcons.user,
                                    color: Colors.green,
                                    size: 20,
                                  );
                                },
                              ),
                            )
                          : const Icon(
                              LucideIcons.user,
                              color: Colors.green,
                              size: 20,
                            ),
                    ),
                    const SizedBox(width: 12),
                    
                    // Replacement guard info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            guard.leaveDays.first.replacementGuard!.name,
                            style: GoogleFonts.cairo(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.accent,
                            ),
                          ),
                          Text(
                            'رقم الشارة: ${guard.leaveDays.first.replacementGuard!.badgeNumber}',
                            style: GoogleFonts.cairo(
                              fontSize: 12,
                              color: AppTheme.accent.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // View details button
                    IconButton(
                      icon: const Icon(
                        LucideIcons.arrowUpRight,
                        color: Colors.green,
                        size: 20,
                      ),
                      onPressed: () {
                        HapticFeedback.selectionClick();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GuardDetailsScreen(
                              guardId: guard.leaveDays.first.replacementGuard!.id,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      LucideIcons.calendar,
                      color: Colors.orange,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'فترة الإجازة: ${DateFormatter.formatDateRange(
                        guard.leaveDays.first.startDate,
                        guard.leaveDays.first.endDate,
                      )}',
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
              ],
              
              const SizedBox(height: 12),
              
              // View details button
              Center(
                child: TextButton.icon(
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GuardDetailsScreen(guardId: guard.id),
                      ),
                    );
                  },
                  icon: const Icon(
                    LucideIcons.info,
                    size: 18,
                  ),
                  label: Text(
                    'عرض التفاصيل',
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}