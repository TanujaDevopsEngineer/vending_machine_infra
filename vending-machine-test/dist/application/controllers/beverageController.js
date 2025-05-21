"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.BeverageController = void 0;
require("reflect-metadata");
const tsyringe_1 = require("tsyringe");
const beverageService_1 = require("../../domain/services/beverageService");
const Coin_1 = require("../../domain/models/Coin");
const BadRequest_1 = require("../../domain/models/BadRequest");
const BeverageInfo_1 = require("../dtos/BeverageInfo");
const Beverage_1 = require("../dtos/Beverage");
const Ingredient_1 = require("../dtos/Ingredient");
let BeverageController = class BeverageController {
    beverageService;
    constructor(beverageService) {
        this.beverageService = beverageService;
    }
    GetBeverages(req, res) {
        const beverages = this.beverageService.GetBeverages();
        const beverageList = Object.keys(beverages).map(beverageName => {
            return new BeverageInfo_1.BeverageInfo(beverageName, beverages[beverageName].price);
        });
        res.status(200).json(beverageList).end();
    }
    ;
    GetIngredients(req, res) {
        const ingredients = this.beverageService.GetIngredients();
        const ingredientList = Object.keys(ingredients).map(name => {
            return new Ingredient_1.Ingredient(name, ingredients[name].quantity);
        });
        res.status(200).json(ingredientList).end();
    }
    ;
    async PrepareBeverage(req, res) {
        const { beverageName, sugarLevel, coins } = req.body;
        try {
            const { change, txId } = await this.beverageService.PrepareBeverage(beverageName, sugarLevel, coins.map(x => new Coin_1.Coin(x)));
            return res.status(200).json(new Beverage_1.Beverage(beverageName, change.map(x => x.getDenomination()), txId)).end();
        }
        catch (error) {
            if (error instanceof BadRequest_1.BadRequest) {
                res.statusMessage = error.message;
                return res.sendStatus(400).end();
            }
            else {
                console.log(error);
                return res.sendStatus(500).end();
            }
        }
    }
    ;
};
exports.BeverageController = BeverageController;
exports.BeverageController = BeverageController = __decorate([
    (0, tsyringe_1.autoInjectable)(),
    __metadata("design:paramtypes", [beverageService_1.BeverageService])
], BeverageController);
//# sourceMappingURL=beverageController.js.map