"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
require("reflect-metadata");
const express_1 = require("express");
const tsyringe_1 = require("tsyringe");
const beverageController_1 = require("../../application/controllers/beverageController");
const router = (0, express_1.Router)();
exports.default = () => {
    router.get('/beverages', (req, res) => tsyringe_1.container.resolve(beverageController_1.BeverageController).GetBeverages(req, res));
    router.post('/beverages', (req, res) => tsyringe_1.container.resolve(beverageController_1.BeverageController).PrepareBeverage(req, res));
    router.get('/ingredients', (req, res) => tsyringe_1.container.resolve(beverageController_1.BeverageController).GetIngredients(req, res));
    return router;
};
//# sourceMappingURL=beverageRoutes.js.map