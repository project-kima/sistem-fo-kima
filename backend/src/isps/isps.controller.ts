import {
    Body,
    Controller,
    Delete,
    Get,
    Param,
    ParseIntPipe,
    Patch,
    Post,
} from '@nestjs/common';
import { IspsService } from './isps.service';
import { CreateIspDto } from './dto/create-isp.dto';
import { UpdateIspDto } from './dto/update-isp.dto';

@Controller('api/isps')
export class IspsController {
    constructor(private readonly ispsService: IspsService) { }

    @Get()
    listIsps() {
        return this.ispsService.listIsps();
    }

    @Post()
    createIsp(@Body() payload: CreateIspDto) {
        return this.ispsService.createIsp(payload);
    }

    @Get(':ispId')
    getIspDetail(@Param('ispId', ParseIntPipe) ispId: number) {
        return this.ispsService.getIspDetail(ispId);
    }

    @Patch(':ispId')
    updateIsp(
        @Param('ispId', ParseIntPipe) ispId: number,
        @Body() payload: UpdateIspDto,
    ) {
        return this.ispsService.updateIsp(ispId, payload);
    }

    @Get(':ispId/tenants')
    listIspTenants(@Param('ispId', ParseIntPipe) ispId: number) {
        return this.ispsService.listIspTenants(ispId);
    }

    @Post(':ispId/tenants')
    attachTenant(
        @Param('ispId', ParseIntPipe) ispId: number,
        @Body() payload: { customerId?: number },
    ) {
        return this.ispsService.attachTenant(ispId, payload);
    }

    @Delete(':ispId/tenants/:customerId')
    removeTenant(
        @Param('ispId', ParseIntPipe) ispId: number,
        @Param('customerId', ParseIntPipe) customerId: number,
        @Body() payload?: { mode?: 'this' | 'all' | 'selected'; ispIds?: number[] },
    ) {
        return this.ispsService.removeTenant(ispId, customerId, payload);
    }
}
