{
	description = "Cobalt Renderer";

	inputs = {
		nixpkgs.url = "nixpkgs/nixos-26.05";
	};

	outputs = { self, nixpkgs }:
	let
		supportedSystems = [
			"x86_64-linux"
			# "x86_64-windows"
			# "x86_64-darwin"
			# "aarch64-linux"
			# "aarch64-windows"
			# "aarch64-darwin"
		];
		forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
		nixpkgsFor = forAllSystems (system: import nixpkgs {
			inherit system; overlays = [ self.overlays.default ];
		});
	in
	{
		overlays.default = import ./overlay.nix;

		# checks = forAllSystems (system: with nixpkgsFor.${system};
		# 	cobalt-renderer.tests
		# );

		packages = forAllSystems (system: rec {
			inherit (nixpkgsFor.${system}) cobalt-renderer;
			default = cobalt-renderer;
		});
	};
}
