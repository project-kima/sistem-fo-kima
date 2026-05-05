import { adminRoleConfig } from "./admin/config";
import { ispRoleConfig } from "./isp/config";
import { teknisiRoleConfig } from "./teknisi/config";

export const APP_ROLES = {
    admin: "admin",
    teknisi: "teknisi",
    isp: "isp",
};

export const roleConfigs = {
    [APP_ROLES.admin]: adminRoleConfig,
    [APP_ROLES.teknisi]: teknisiRoleConfig,
    [APP_ROLES.isp]: ispRoleConfig,
};

export function getRoleConfig(roleKey) {
    return roleConfigs[roleKey] ?? roleConfigs[APP_ROLES.admin];
}

export function canAccessSection(roleKey, sectionKey) {
    const roleConfig = getRoleConfig(roleKey);
    return roleConfig.allowedSections.includes(sectionKey);
}

export function canAccessRoute(roleKey, route) {
    const roleConfig = getRoleConfig(roleKey);

    if (!roleConfig.allowedRouteTypes.includes(route.type)) {
        return false;
    }

    if (route.type === "section" && route.sectionKey) {
        return canAccessSection(roleKey, route.sectionKey);
    }

    return true;
}
