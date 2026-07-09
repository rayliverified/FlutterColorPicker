/// Minimal local Soft SaaS UI subset used by the standalone example.
///
/// This barrel intentionally exports only the components/tokens referenced by
/// `example/lib`, avoiding a vendored copy of the full `soft_saas_ui` package.
library;

export 'local_soft_saas/soft_saas/design_tokens.dart';
export 'local_soft_saas/soft_saas/neumorphic_shadows.dart';
export 'local_soft_saas/soft_saas/theme.dart';
export 'local_soft_saas/soft_saas/typography.dart';
export 'local_soft_saas/soft_saas/components/button.dart';
export 'local_soft_saas/soft_saas/components/panel.dart';
export 'local_soft_saas/soft_saas/components/tabs.dart';
