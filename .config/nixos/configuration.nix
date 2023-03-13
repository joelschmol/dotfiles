# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:
let
  configure-gtk = pkgs.writeTextFile {
    name = "configure-gtk";
    destination = "/bin/configure-gtk";
    executable = true;
    text =
      let
        schema = pkgs.gsettings-desktop-schemas;
        datadir = "${schema}/share/gsettings-schemas/${schema.name}";
      in
      ''
        export XDG_DATA_DIRS=${datadir}:$XDG_DATA_DIRS
        gnome_schema=org.gnome.desktop.interface
        gsettings set $gnome_schema gtk-theme 'Breeze-Dark'
        gsettings set $gnome_schema cursor-theme 'breeze_cursors'
      '';
  };
in
{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";
  boot.kernelParams = [ "module_blacklist=i915" "nvidia-drm.modeset=1" ];
  boot.kernelPackages = pkgs.linuxKernel.packages.linux_6_2;

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;
  # Enable flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  # Set your time zone.
  time.timeZone = "Asia/Karachi";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.utf8";

  # Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = "";
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.anas = {
    isNormalUser = true;
    description = "anas";
    extraGroups = [ "networkmanager" "wheel" "vboxusers" ];
    packages = with pkgs; [
      kitty
      discord
      wine
      rustup
      youtube-dl
      jetbrains.clion
      prismlauncher
      libnotify
      graphite-gtk-theme
      firefox
      distrobox
    ];
  };
  # steam crap
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };
  nixpkgs.overlays = [
    (self: super: {
      waybar = super.waybar.overrideAttrs (oldAttrs: {
        mesonFlags = oldAttrs.mesonFlags ++ [ "-Dexperimental=true" ];
        patchPhase = ''
          sed -i 's/zext_workspace_handle_v1_activate(workspace_handle_);/const std::string command = "hyprctl dispatch workspace " + name_;\n\tsystem(command.c_str());/g' src/modules/wlr/workspace_manager.cpp
        '';
      });
    })
  ];
  virtualisation.docker.rootless.enable = true;
  nixpkgs.config.packageOverrides = pkgs: {
    steam = pkgs.steam.override {
      extraPkgs = pkgs: with pkgs; [
        libgdiplus
      ];
    };
  };
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  services.xserver = {
    enable = true;
    videoDrivers = [ "intel" ];
    libinput.enable = true;
    displayManager.sx.enable = true;
  };
  xdg.portal = {
    enable = true;
    wlr.enable = true;
  };
  programs.fish.enable = true;
  programs.gnupg.agent.enable = true;
  services.gnome.core-os-services.enable = true;
  programs.xwayland.enable = true;
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };
  hardware.opengl.enable = true;
  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.stable;
  services.picom.enable = true;
  hardware.bluetooth.enable = true;
  programs.dconf.enable = true;
  programs.waybar.enable = true;
  services.printing = {
    enable = true;
    drivers = with pkgs; [
      canon-cups-ufr2
    ];
  };
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    noto-fonts-cjk-sans
    libopus
    libsodium
    ffmpeg
    file
    git
    gcc
    lxappearance
    xmrig
    wayland
    wlroots
    libsForQt5.breeze-gtk
    libsForQt5.breeze-icons
    grapejuice
    cups
    libreoffice
    binutils
    elogind
    neofetch
    neovim
    python3
    wget
    libstdcxx5
    wofi
    xcb-util-cursor
    gnome.adwaita-icon-theme
    glib
    libseat
    home-manager
    configure-gtk
    wl-clipboard
    grim
    slurp
    waybar
    hyprpaper
    swaybg
    swayidle
    imv
    mpv
    xfce.thunar
    spotify
  ];
  services.blueman.enable = true;
  security.doas = {
    enable = true;
    extraRules = [{
      persist = true;
      keepEnv = true;
      groups = [
        "wheel"
      ];
    }];
  };
  virtualisation.virtualbox.host.enable = true;
  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    settings = {
      passwordAuthentication = false;
    };
  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "unstable"; # Did you read the comment?

}
