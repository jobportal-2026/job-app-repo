"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const common_1 = require("@nestjs/common");
const config_1 = require("@nestjs/config");
const core_1 = require("@nestjs/core");
const swagger_1 = require("@nestjs/swagger");
const helmet_1 = __importDefault(require("helmet"));
const app_module_1 = require("./app.module");
const app_constants_1 = require("./common/constants/app.constants");
async function bootstrap() {
    const app = await core_1.NestFactory.create(app_module_1.AppModule);
    const configService = app.get(config_1.ConfigService);
    app.setGlobalPrefix(app_constants_1.API_PREFIX);
    app.use((0, helmet_1.default)());
    const origins = (configService.get('CORS_ORIGINS') ?? '')
        .split(',')
        .map((origin) => origin.trim())
        .filter(Boolean);
    app.enableCors({
        origin: origins.length > 0 ? origins : true,
        credentials: true,
    });
    app.useGlobalPipes(new common_1.ValidationPipe({
        whitelist: true,
        forbidNonWhitelisted: true,
        transform: true,
    }));
    const swaggerConfig = new swagger_1.DocumentBuilder()
        .setTitle('Job Portal API')
        .setDescription('Job Portal backend API documentation')
        .setVersion('1.0')
        .addBearerAuth({ type: 'http', scheme: 'bearer' }, 'access')
        .addBearerAuth({ type: 'http', scheme: 'bearer' }, 'admin')
        .build();
    const document = swagger_1.SwaggerModule.createDocument(app, swaggerConfig);
    swagger_1.SwaggerModule.setup(app_constants_1.SWAGGER_PATH, app, document);
    const port = configService.get('PORT') ?? 5000;
    await app.listen(port);
}
bootstrap();
//# sourceMappingURL=main.js.map