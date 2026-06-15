import { defineConfig } from "vitepress";

const siteURL = "https://shuowen.qiyang.dev";

// https://vitepress.dev/reference/site-config
export default defineConfig({
  title: "Shuowen",
  description: "Offline reader for Shuowen Jiezi (说文解字)",
  head: [
    ["link", { rel: "icon", href: "/logo.png" }],
    ["meta", { property: "og:site_name", content: "Shuowen" }],
    ["meta", { property: "og:type", content: "website" }],
  ],
  sitemap: {
    hostname: siteURL,
  },
  themeConfig: {
    // https://vitepress.dev/reference/default-theme-config
    nav: [
      { text: "Privacy", link: "/privacy" },
      { text: "Terms", link: "/terms" },
      { text: "Support", link: "/support" },
    ],

    sidebar: [
      { text: "Privacy", link: "/privacy" },
      { text: "Terms", link: "/terms" },
      { text: "Support", link: "/support" },
    ],

    socialLinks: [
      {
        icon: "github",
        link: "https://github.com/qiyangdev/Shuowen",
      },
    ],
  },
});
