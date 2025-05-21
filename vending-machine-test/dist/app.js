"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = __importDefault(require("express"));
const http_1 = __importDefault(require("http"));
const body_parser_1 = __importDefault(require("body-parser"));
const cors_1 = __importDefault(require("cors"));
const beverageRoutes_1 = __importDefault(require("./infrastructure/routes/beverageRoutes"));
const helmet_1 = __importDefault(require("helmet"));
const dotenv_1 = __importDefault(require("dotenv"));
dotenv_1.default.config();
const app = (0, express_1.default)();
app.use((0, cors_1.default)({
    credentials: true
}));
app.use((0, helmet_1.default)());
app.use(body_parser_1.default.json());
const server = http_1.default.createServer(app);
const PORT = 3000;
server.listen(PORT, () => console.log(`Server is running on http://localhost:${PORT}/`));
app.use('/', (0, beverageRoutes_1.default)());
//# sourceMappingURL=app.js.map