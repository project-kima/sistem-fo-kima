export const ispMenuItems = [
    { key: "dashboard", label: "Dashboard", icon: "dashboard" },
    { key: "customers", label: "Tenant", icon: "groups" },
    { key: "monitoring", label: "Monitoring", icon: "monitor_heart" },
];

export const ispRoleConfig = {
    key: "isp",
    label: "ISP",
    profileTitle: "User ISP",
    profileSubtitle: "Mitra",
    defaultSection: "customers",
    menuItems: ispMenuItems,
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
        "customer-detail",
        "isp-detail",
        "not-found",
    ],
};
