# Publishing Checklist for loro_dart

This checklist ensures you're ready to publish to pub.dev.

## Pre-Publication Checklist

### 1. Code Quality
- [ ] All tests pass: `flutter test`
- [ ] No analysis issues: `dart analyze`
- [ ] Code is formatted: `dart format .`
- [ ] Rust tests pass: `cd rust && cargo test`
- [ ] Rust clippy has no warnings: `cd rust && cargo clippy`

### 2. Documentation
- [ ] README.md is complete and accurate
- [ ] CHANGELOG.md is updated with version and changes
- [ ] API documentation is complete (dartdoc comments)
- [ ] Examples are working and documented
- [ ] LICENSE file is present and correct

### 3. Package Configuration
- [ ] pubspec.yaml has correct version
- [ ] pubspec.yaml has all required fields:
  - name
  - description
  - version
  - homepage or repository
- [ ] Dependencies are properly specified
- [ ] Platform support is correctly declared

### 4. Build Verification
- [ ] Native libraries built for all platforms:
  - [ ] Android (arm64-v8a, armeabi-v7a, x86, x86_64)
  - [ ] iOS (device and simulator)
  - [ ] Windows (x64)
  - [ ] Linux (x64)
  - [ ] macOS (universal binary)
- [ ] Libraries are in correct locations
- [ ] Example app runs on each platform

### 5. Dart Bindings
- [ ] Bindings generated successfully: `dart run tool/generate_bindings.dart`
- [ ] Generated code compiles without errors
- [ ] FFI loader works on all platforms

### 6. Testing
- [ ] Unit tests cover main functionality
- [ ] Integration tests pass on real devices
- [ ] Example app demonstrates key features
- [ ] Memory leaks checked (dispose methods work)

### 7. Version Control
- [ ] All changes committed
- [ ] Git tags created for version
- [ ] loro-ffi submodule is on correct commit
- [ ] .gitignore is properly configured

### 8. Legal & Compliance
- [ ] License is compatible (MIT)
- [ ] Third-party licenses acknowledged
- [ ] No sensitive data in repository
- [ ] Attribution to loro-dev project

## Publishing Commands

### Dry Run (Recommended First)
```bash
# Verify package before publishing
dart pub publish --dry-run
```

### Actual Publishing
```bash
# Publish to pub.dev
dart pub publish
```

### After Publishing
- [ ] Verify package appears on pub.dev
- [ ] Test installation: `flutter pub add loro_dart`
- [ ] Check pub.dev package page for issues
- [ ] Update repository README badges
- [ ] Create GitHub release with tag
- [ ] Announce on relevant channels

## Common Issues

### Issue: "Package validation failed"
- Check all required files are present
- Verify pubspec.yaml format
- Ensure no errors in analysis

### Issue: "Native libraries not found"
- Verify libraries are in platform-specific directories
- Check ffiPlugin configuration in pubspec.yaml
- Ensure library names match platform conventions

### Issue: "Analysis errors"
- Run `dart analyze` and fix all issues
- Check generated code for problems
- Verify imports and exports

### Issue: "Size too large"
- Native libraries can be large (this is expected for FFI packages)
- Consider using lazy loading for non-critical platforms
- Document expected package size

## Version Numbering

Follow [Semantic Versioning](https://semver.org/):

- **MAJOR** version: Incompatible API changes
- **MINOR** version: Add functionality (backwards-compatible)
- **PATCH** version: Bug fixes (backwards-compatible)

## Post-Publication Tasks

1. **Monitor pub.dev** for:
   - Package health score
   - User feedback
   - Compatibility issues

2. **GitHub Release**:
   ```bash
   git tag v1.0.0
   git push origin v1.0.0
   ```

3. **Documentation**:
   - Update project website if applicable
   - Share on social media/forums
   - Update any tutorial content

4. **Support**:
   - Monitor GitHub issues
   - Respond to questions promptly
   - Plan next version based on feedback

## Resources

- [Publishing packages - Dart](https://dart.dev/tools/pub/publishing)
- [Flutter plugin development](https://docs.flutter.dev/development/packages-and-plugins/developing-packages)
- [Semantic Versioning](https://semver.org/)
- [pub.dev policies](https://pub.dev/policy)

---

Last updated: 2025-12-16
