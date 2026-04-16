import { Module } from '@nestjs/common';
import { StoreModule } from '../store/store.module';
import { IspsController } from './isps.controller';
import { IspsService } from './isps.service';

@Module({
    imports: [StoreModule],
    controllers: [IspsController],
    providers: [IspsService],
    exports: [IspsService],
})
export class IspsModule { }
