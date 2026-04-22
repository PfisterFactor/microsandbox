%global debug_package %{nil}
%global __os_install_post %{nil}
%global _build_id_links none

Name:           microsandbox
Version:        %{_version}
Release:        0.%{_buildnum}.git%{_shortsha}%{?dist}
Summary:        MicroVM-based sandbox runtime (msb CLI)
License:        Apache-2.0
URL:            https://github.com/%{_owner}/microsandbox
ExclusiveArch:  x86_64 aarch64

Source0:        msb
Source1:        libkrunfw.so.5.2.1
Source2:        LICENSE

Requires(post):   /sbin/ldconfig
Requires(postun): /sbin/ldconfig

%description
microsandbox runs untrusted code in microVMs backed by libkrun/KVM.
This package ships the msb CLI and its vendored libkrunfw runtime library.

%prep

%build

%install
install -D -m 0755 %{SOURCE0} %{buildroot}%{_bindir}/msb
# Install libkrunfw to /usr/lib (NOT /usr/lib64): msb's hardcoded lookup
# searches /usr/bin/ and /usr/lib/ only (../lib relative to the binary).
# It does not consult ld.so.cache or /usr/lib64/.
install -D -m 0755 %{SOURCE1} %{buildroot}/usr/lib/libkrunfw.so.5.2.1
ln -s libkrunfw.so.5.2.1 %{buildroot}/usr/lib/libkrunfw.so.5
install -D -m 0644 %{SOURCE2} %{buildroot}%{_defaultlicensedir}/%{name}/LICENSE

%post -p /sbin/ldconfig
%postun -p /sbin/ldconfig

%files
%license %{_defaultlicensedir}/%{name}/LICENSE
%{_bindir}/msb
/usr/lib/libkrunfw.so.5.2.1
/usr/lib/libkrunfw.so.5

%changelog
* %{_changelog_date} Eric Pfister <eric.pfister@cyncly.com> - %{version}-%{release}
- Automated build from commit %{_shortsha}
