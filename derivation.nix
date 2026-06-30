{
	stdenv,
	lib,
	applyPatches,
	fetchurl,
	fetchzip,
	fetchpatch,
	fetchFromGitHub,
	git,
	cmake,
	ninja,
	pkg-config,
	python3,
	libxslt,
	libglvnd,
	libgbm,
	libxau,
	libxdmcp,
	libxcb,
	libx11,
	libxrandr,
	libffi,
	libxkbcommon,
	libdecor,
	libxcursor,
	libxi,
	libxscrnsaver,
	libxtst,
	vulkan-loader,
	zenity,
	wayland-scanner,
	wayland-protocols,
	egl-wayland,
	wayland,
	cairo,
	sdl3,# ? null,
	cobalt_use_vvl ? false
	# cobalt_build_type ? "release"
}:

let
	cobaltCacheDir = "build/External/Cache";

	symlinkContent = out: drv: "ln -s ${drv} $(pwd)/${cobaltCacheDir}/${out}";
	symlinkContentFromGitHub = out: repo:
		symlinkContent out (fetchFromGitHub repo);
	symlinkContentFromGitHubPatched = name: repo: patches:
		symlinkContent name (applyPatches {
			name = "patched-${name}";
			src = fetchFromGitHub repo;
			patches = patches;
		});
	symlinkContentZip = name: zip: symlinkContent name (fetchzip zip);
	symlinkContentUrl = name: url: symlinkContent name (fetchurl url);

	symlinkCache =
		lib.concatMapStrings (sym: "${sym}\n") ([
			# General Utility Libraries
			(symlinkContentFromGitHubPatched "zlib" {
				owner = "madler";
				repo = "zlib";
				rev = "v1.3.1";
				hash = "sha256-TkPLWSN5QcPlL9D0kc/yhH0/puE9bFND24aj5NVDKYs=";
			} [ (fetchpatch {
				url = "https://github.com/savushkin-r-d/zlib/commit/feee7dd9d6559571e9821493f890df73422f9f8e.patch";
				hash = "sha256-4g1esOXzwi8uKaZqbgWRvCioE53AKU4XeCvYa26qklA=";
			}) ])
			(symlinkContentFromGitHub "libpng" {
				owner = "pnggroup";
				repo = "libpng";
				rev = "v1.6.51";
				hash = "sha256-4txg9W8LqdCtvVZ2hZGyWRVTDxTIn7Mtl9joBrUtFZI=";
			})
			(symlinkContentFromGitHubPatched "gli" {
				owner = "g-truc";
				repo = "gli";
				rev = "3542f8830178061e0661f5df1e89d36ba7d7b0ab";
				hash = "sha256-EbDwbIsf4qu60FCMJUv4KNu/UoyM7grpEwd0+9A4O6I=";
			} [ (fetchpatch {
				url = "https://github.com/g-truc/gli/pull/164.patch";
				hash = "sha256-PX3wXLSjtvhKK6Or9rRTgb3OPFbOxUyr30sIaPp3+VY=";
			}) ])

			# Math Libraries
			(symlinkContentFromGitHub "glm" {
				owner = "g-truc";
				repo = "glm";
				rev = "1.0.2";
				hash = "sha256-2xKv1nO+OdwA0r+I9OZ+OCL9dJFg/LJsQfIvIF76vc0=";
			})
			(symlinkContentZip "half" {
				url = "mirror://sourceforge/half/2.2.0/half-2.2.0.zip";
				hash = "sha256-ZdGgBMZylFgkvs/XVBnvgBY2EYSHRLY3S4YwXjshpOY=";
				stripRoot = false;
			})

			# OpenGL Libraries
			(symlinkContentFromGitHub "OpenGLRegistry" {
				owner = "KhronosGroup";
				repo = "OpenGL-Registry";
				rev = "8f9b0ca1a8eafa2cebde3ff982629e7913d2817f";
				hash = "sha256-1iNsFYyQGiptEGJMi9XtF0zETZLtCiM9uN06/Pnno5I=";
			})

			# Shader Utilities
			(symlinkContentFromGitHub "SPIRV-Cross" {
				owner = "KhronosGroup";
				repo = "SPIRV-Cross";
				rev = "9daa7fe0a36dbe5c5b810d74d2cc43b202407d57";
				hash = "sha256-VPTwAfxu2bY22D+HdzmvmSUwTMaBApmY76N7vHBfzVY=";
			})
			(symlinkContentFromGitHub "SPIRV-Headers" {
				owner = "KhronosGroup";
				repo = "SPIRV-Headers";
				rev = "sdk-1.3.216.0";
				hash = "sha256-qYhFoRrQOlvYvVXhIFsa3dZuORDpZyVC5peeYmGNimw=";
			})
			(symlinkContentFromGitHubPatched "SPIRV-Tools" {
				owner = "KhronosGroup";
				repo = "SPIRV-Tools";
				rev = "sdk-1.3.216.0";
				hash = "sha256-NWpFSRoxtYWi+hLUt9gpw0YScM3shcUwv9yUmbivRb0=";
			} [
				./External/ShaderUtilities/SPIRV-Tools.patch
			])
			(symlinkContentFromGitHub "glslang" {
				owner = "KhronosGroup";
				repo = "glslang";
				rev = "11.10.0";
				hash = "sha256-sjidkiPtRADhyOEKDb2cHCBXnFjLwk2F5Lppv5/fwNQ=";
			})

			# Vulkan Libraries
			(symlinkContentFromGitHub "Vulkan-Headers" {
				owner = "KhronosGroup";
				repo = "Vulkan-Headers";
				rev = "v1.3.261";
				hash = "sha256-zKHew7SGUq1C3XGp/HrCle6KyqB4cziPcTYVqAr814s=";
			})
			(symlinkContentFromGitHubPatched "Vulkan-Loader" {
				owner = "KhronosGroup";
				repo = "Vulkan-Loader";
				rev = "v1.3.261";
				hash = "sha256-5QCVHfvjE98EnL2Dr7g9fdrJAg+np1Q6hgqcuZCWReQ=";
			} [
				./External/VulkanLibraries/Vulkan-Loader.patch
			])
			(symlinkContentFromGitHub "VulkanMemoryAllocator" {
				owner = "GPUOpen-LibrariesAndSDKs";
				repo = "VulkanMemoryAllocator";
				rev = "v3.4.0";
				hash = "sha256-LBZJcom7G7maF9wpUVeVEJQAJwGy6365INk3VD0/0PM=";
			})
		] ++ lib.optionals cobalt_use_vvl [
			# Vulkan Libraries
			(symlinkContentFromGitHubPatched "Vulkan-ValidationLayers" {
				owner = "KhronosGroup";
				repo = "Vulkan-ValidationLayers";
				rev = "v1.4.336";
				hash = "sha256-EuXKMGZ9gaTySwX1/6iON5owLaBo1vodDWcOz69mP/4=";
			} [
				./External/VulkanLibraries/Vulkan-ValidationLayers.patch
			])
		] ++ lib.optionals (true || sdl3 == null) [
			(symlinkContentFromGitHub "sdl3" {
				owner = "libsdl-org";
				repo = "SDL";
				rev = "release-3.4.0";
				hash = "sha256-/A1y/NaZVebzI58F4TlwtDwuzlcA33Y1YuZqd5lz/Sk=";
			})
		] ++ lib.optionals stdenv.hostPlatform.isLinux [
		] ++ lib.optionals stdenv.hostPlatform.isDarwin [
			# Vulkan Libraries
			(symlinkContentUrl "VulkanSDK" {
				url = "https://sdk.lunarg.com/sdk/download/1.4.341.0/mac/vulkan_sdk.zip";
				hash = "sha256-O4r399t0tL2gLckVA87CiKtwrr/ic/+Yu4zrq/BLGW4=";
			})
		] ++ lib.optionals stdenv.hostPlatform.isWindows [
			# Direct3D12 Libraries
			(symlinkContentFromGitHubPatched "PixEvents" {
				owner = "Microsoft";
				repo = "PixEvents";
				rev = "3a7e70dde7bf54f02f9d2e9dd6d3350c6cfb962f";
				hash = "sha256-KvJjdAwtCb+vibu3F+kiivtelsYMSZgg/mysa4K/2CE=";
			} [
				./External/Direct3D12Libraries/PixEvents/PixEvents.patch
			])
			(symlinkContentFromGitHubPatched "DXSamples" {
				owner = "Microsoft";
				repo = "DirectX-Graphics-Samples";
				rev = "1704d8883ea74a73d332516bb6d990a134abaebd";
				hash = "sha256-b6isfN3PjzW/K3A5/HGS7FSn6cj0MsYpST+KNSxpsXM=";
			} [
				./External/Direct3D12Libraries/D3DX12Residency.patch
			])
			(symlinkContentFromGitHub "DirectX-Headers" {
				owner = "Microsoft";
				repo = "DirectX-Headers";
				rev = "v1.606.3-r1";
				hash = "sha256-b6isfN3PjzW/K3A5/HGS7FSn6cj0MsYpST+KNSxpsXM=";
			})
			(symlinkContentFromGitHub "D3D12MemoryAllocator" {
				owner = "GPUOpen-LibrariesAndSDKs";
				repo = "D3D12MemoryAllocator";
				rev = "eace86c42911c8812841043d8f34c7574acee7da";
				hash = "sha256-b6isfN3PjzW/K3A5/HGS7FSn6cj0MsYpST+KNSxpsXM=";
			})
			(symlinkContentZip "DirectXShaderCompilerOfficial" {
				url = "https://github.com/microsoft/DirectXShaderCompiler/releases/download/v1.9.2602/dxc_2026_02_20.zip";
				hash = "sha256-lc3yr3BQs7qiFClJJNM4PBkYfwvQenHko0jzCy/8ZS8=";
				stripRoot = false;
			})
		]);
in
stdenv.mkDerivation (finalAttrs: {
	name = "Cobalt-${finalAttrs.version}";
	version = "v2.0.0";
	meta.maintainers = [{
		name = "LAK132";
		github = "LAK132";
		githubId = 1386467;
	}];

	src = ./.;

	nativeBuildInputs = [
		git
		cmake
		ninja
		pkg-config
		python3
		libxslt
	] ++ lib.optionals stdenv.hostPlatform.isLinux [
	] ++ lib.optionals stdenv.hostPlatform.isWindows [
	] ++ lib.optionals stdenv.hostPlatform.isDarwin [
	];

	buildInputs = [
	# ] ++ lib.optionals (sdl3 != null) [
		sdl3
	] ++ lib.optionals stdenv.hostPlatform.isLinux [
		libxcb
		libx11
		libglvnd
		libgbm
		libxau
		libxdmcp
		libxrandr
		libffi
		libxkbcommon
		libdecor
		libxcursor
		libxi
		libxscrnsaver
		libxtst
		zenity
		egl-wayland
		wayland
		wayland-scanner
		wayland-protocols
		cairo
	] ++ lib.optionals stdenv.hostPlatform.isWindows [
	] ++ lib.optionals stdenv.hostPlatform.isDarwin [
	];

	cmakeFlags = [
		(lib.cmakeFeature "CMAKE_POLICY_VERSION_MINIMUM" "3.5")
		(lib.cmakeBool "FETCHCONTENT_FULLY_DISCONNECTED" true)

		(lib.cmakeBool "COBALT_BUILD_TESTS" false)
		(lib.cmakeBool "COBALT_BUILD_UTILITIES" false)
		(lib.cmakeBool "COBALT_BUILD_EXAMPLES" true)

		(lib.cmakeBool "COBALT_OPENGL_USE_EGL" true)
		(lib.cmakeBool "COBALT_BUILD_VULKAN_VALIDATION_LAYERS" cobalt_use_vvl)

		(lib.cmakeBool "COBALT_USE_SDL3" true)
		# (lib.cmakeBool "COBALT_USE_LOCAL_SDL3" (sdl3 != null))
		(lib.cmakeBool "COBALT_USE_LOCAL_SDL3" true)

		(lib.cmakeBool "COBALT_RUN_MSVC_STATIC_ANALYSIS" false)
		(lib.cmakeBool "COBALT_CLANG_FORMAT_ON_ALL" false)
		(lib.cmakeBool "COBALT_CLANG_TIDY_ON_ALL" false)
		(lib.cmakeBool "COBALT_INHERIT_SYSTEM_INSTALL_PATH" true)
	] ++ lib.optionals cobalt_use_vvl [
	] ++ lib.optionals stdenv.hostPlatform.isLinux [
	] ++ lib.optionals stdenv.hostPlatform.isDarwin [
	] ++ lib.optionals stdenv.hostPlatform.isWindows [
	];

	patchPhase = ''
		substituteInPlace Examples/SDLExample/CMakeLists.txt \
			--replace-fail "SDL3::SDL3" "SDL3"
		mkdir -p ${cobaltCacheDir}
		${symlinkCache}
	'';

	# passthru.tests = {
	# };
})
