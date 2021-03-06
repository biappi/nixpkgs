{stdenv, fetchurl, cmake, ninja, jq, python3, gnome3, wrapGAppsHook}:

let
  version = "9";

  inherit (python3.pkgs) python pygobject3 requests;
in stdenv.mkDerivation rec {
  name = "chrome-gnome-shell-${version}";

  src = fetchurl {
    url = "mirror://gnome/sources/chrome-gnome-shell/${version}/${name}.tar.xz";
    sha256 = "0j6lzlp3jvkpnkk8s99y3m14xiq94rjwjzy2pbfqgv084ahzmz8i";
  };

  nativeBuildInputs = [ cmake ninja jq wrapGAppsHook ];
  buildInputs = [ gnome3.gnome_shell python pygobject3 requests ];

  preConfigure = ''
    substituteInPlace CMakeLists.txt --replace "/etc" "$out/etc"
  '';
  # cmake setup hook changes /etc/opt into /var/empty
  dontFixCmake = true;

  cmakeFlags = [ "-DBUILD_EXTENSION=OFF" ];
  wrapPrefixVariables = [ "PYTHONPATH" ];

  meta = with stdenv.lib; {
    description = "GNOME Shell integration for Chrome";
    longDescription = ''
      To use the integration, install the <link xlink:href="https://wiki.gnome.org/Projects/GnomeShellIntegrationForChrome/Installation">browser extension</link>, and then set <option>services.gnome3.chrome-gnome-shell.enable</option> to <literal>true</literal>. For Firefox based browsers, you will also need to build the wrappers with <option>nixpkgs.config.firefox.enableGnomeExtensions</option> set to <literal>true</literal>.
    '';
    license = licenses.gpl3;
    maintainers = gnome3.maintainers;
    platforms = platforms.linux;
  };
}
