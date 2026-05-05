export const teknisiMenuItems = [
    { key: "dashboard", label: "Dashboard", icon: "dashboard" },
    { key: "customers", label: "Pelanggan", icon: "groups" },
    { key: "monitoring", label: "Monitoring", icon: "monitor_heart" },
];

export const teknisiRoleConfig = {
    key: "teknisi",
    label: "Teknisi",
    profileTitle: "Teknisi",
    profileSubtitle: "Operasional",
    defaultSection: "monitoring",
    menuItems: teknisiMenuItems,
    capabilities: {
        canCreateIsp: false,
        canCreateTenant: false,
        canEditIsp: false,
        canDeleteIsp: false,
        canEditTenant: false,
        canDeleteTenant: false,
    },
    allowedSections: ["dashboard", "customers", "monitoring"],
    allowedRouteTypes: [
        "redirect",
        "login",
        "section",
        "monitoring-fullscreen",
        "customer-jalur-planner",
        "customer-jalur-fullscreen",
        "customer-jalur",
        "customer-detail",
        "isp-detail",
        "not-found",
    ],
};
