/** @type {import('tailwindcss').Config} */
export default {
    content: [
        "./index.html",
        "./src/**/*.{js,ts,jsx,tsx}",
    ],
    darkMode: "class",
    theme: {
        extend: {
            colors: {
                /* ── Primary ── */
                "primary": "#745b00",
                "primary-container": "#F5C300",
                "on-primary": "#ffffff",
                "on-primary-container": "#5a4600",

                /* ── Secondary ── */
                "secondary": "#00687b",
                "on-secondary": "#ffffff",
                "secondary-container": "#b3ebf9",
                "on-secondary-container": "#004e5d",

                /* ── Surfaces ── */
                "surface": "#fbf9f9",
                "surface-container": "#f0eeee",
                "surface-container-low": "#f5f3f3",
                "surface-container-lowest": "#ffffff",
                "surface-container-high": "#eae8e8",
                "surface-container-highest": "#e4e2e2",
                "surface-dim": "#dcdada",
                "surface-bright": "#fbf9f9",
                "surface-variant": "#e8e1d5",

                /* ── On-Surface ── */
                "on-surface": "#1b1c1c",
                "on-surface-variant": "#5f5e5c",
                "on-background": "#1b1c1c",
                "background": "#fbf9f9",

                /* ── Outline ── */
                "outline": "#918f8d",
                "outline-variant": "#c9c6c3",

                /* ── Error ── */
                "error": "#ba1a1a",
                "error-container": "#ffdad6",
                "on-error": "#ffffff",
                "on-error-container": "#93000a",

                /* ── Success ── */
                "success": "#16a34a",

                /* ── Inverse ── */
                "inverse-surface": "#313030",
                "inverse-on-surface": "#f3f0f0",
                "inverse-primary": "#e8c43a",

                /* ── Misc legacy tokens kept for compatibility ── */
                "surface-tint": "#745b00",
                "primary-fixed": "#ffe07d",
                "primary-fixed-dim": "#ccaa00",
                "tertiary": "#6e5d00",
                "tertiary-container": "#fff0b3",
                "on-tertiary": "#ffffff",
                "on-tertiary-container": "#534600",
            },
            borderRadius: {
                "DEFAULT": "0.25rem",
                "lg": "0.5rem",
                "xl": "0.75rem",
                "2xl": "1rem",
                "3xl": "1.5rem",
                "full": "9999px"
            },
            fontFamily: {
                "headline": ["Manrope"],
                "body": ["Inter"],
                "label": ["Inter"],
                "manrope": ["Manrope"]
            },
            boxShadow: {
                "glass": "0 8px 32px 0 rgba(116, 91, 0, 0.04)",
                "glass-hover": "0 12px 40px 0 rgba(116, 91, 0, 0.08)",
                "glass-lg": "0 16px 48px 0 rgba(116, 91, 0, 0.06)",
                "soft": "0 2px 8px 0 rgba(27, 28, 28, 0.04)",
                "card": "0 1px 3px 0 rgba(27, 28, 28, 0.06), 0 1px 2px -1px rgba(27, 28, 28, 0.06)",
            }
        },
    },
    plugins: [],
}