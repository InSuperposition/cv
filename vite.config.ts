import path from "node:path";
import { reactRouter } from "@react-router/dev/vite";
import { defineConfig } from "vite";
import devtoolsJson from "vite-plugin-devtools-json";
import tsconfigPaths from "vite-tsconfig-paths";

export default defineConfig({
	plugins: [devtoolsJson(), reactRouter(), tsconfigPaths()],
	resolve: {
		alias: {
			"@atomic-identity/form":
				process.env.VITE_IMPORT_SOURCE === "dist"
					? path.resolve(__dirname, "../form/dist")
					: path.resolve(__dirname, "../form/src"),
		},
	},
});
