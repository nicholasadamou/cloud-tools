import { resolve } from "path";

/** @type {import('next').NextConfig} */
const nextConfig = {
  experimental: {
    externalDir: true, // Allow importing files from outside the Next.js root directory
  },
  webpack: (config, { isServer }) => {
    // Add aliases for root and client lib directories
    config.resolve.alias = {
      ...config.resolve.alias,
      "@/root-lib": resolve(process.cwd(), "..", "lib"),
    };
    return config;
  },
};

export default nextConfig;
