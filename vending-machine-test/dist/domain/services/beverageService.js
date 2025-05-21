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
exports.BeverageService = void 0;
require("reflect-metadata");
const Beverage_1 = require("../models/Beverage");
const recipeRepository_1 = require("../../infrastructure/repositories/recipeRepository");
const ingredientsRepository_1 = require("../../infrastructure/repositories/ingredientsRepository");
const constants_1 = require("../constants");
const tsyringe_1 = require("tsyringe");
const Coin_1 = require("../models/Coin");
const BadRequest_1 = require("../models/BadRequest");
let BeverageService = class BeverageService {
    recipeRepository;
    ingredientsRepository;
    constructor(recipeRepository, ingredientsRepository) {
        this.recipeRepository = recipeRepository;
        this.ingredientsRepository = ingredientsRepository;
    }
    GetBeverages() {
        return this.recipeRepository.GetAllRecipes();
    }
    GetIngredients() {
        return this.ingredientsRepository.getAllIngredients();
    }
    async PrepareBeverage(beverageName, sugarLevel, coins) {
        this.validate(beverageName, sugarLevel, coins);
        const recipe = this.recipeRepository.GetRecipe(beverageName);
        if (!recipe) {
            throw new BadRequest_1.BadRequest('Beverage not found');
        }
        const amount = this.calculateSum(coins);
        if (recipe.price > amount) {
            throw new BadRequest_1.BadRequest('Insufficient funds');
        }
        const beverage = new Beverage_1.Beverage(beverageName, recipe.recipe.getIngredients(), sugarLevel);
        if (beverage.prepare(this.ingredientsRepository.getAllIngredients())) {
            const change = amount - recipe.price;
            // const txId = await new TransactionBroadcaster().SendAsync(JSON.stringify({ "beverage": beverageName, "paid": amount, "change": change }));
            const txId = '1234567890abcdef'; // Placeholder for transaction ID
            return { change: this.calculateChange(change), txId };
        }
        else {
            throw new BadRequest_1.BadRequest(`Cannot prepare ${beverageName}. Not enough ingredients.`);
        }
    }
    validate(beverageName, sugarLevel, coins) {
        if (!beverageName || !coins) {
            throw new BadRequest_1.BadRequest("beverageName and coins are required");
        }
        if (!Number.isInteger(sugarLevel) || sugarLevel < 1 || sugarLevel > 5) {
            throw new BadRequest_1.BadRequest("sugarLevel must be a whole number between 1 and 5");
        }
    }
    calculateSum(coins) {
        const sum = coins.reduce((sum, coin) => sum + coin.getDenomination(), 0);
        return Math.round(sum * 100) / 100; // Round to 2 decimal places
    }
    calculateChange(amount) {
        const change = [];
        let remainingAmount = amount;
        for (const denomination of constants_1.DENOMINATIONS) {
            while (remainingAmount >= denomination) {
                change.push(new Coin_1.Coin(denomination));
                remainingAmount -= denomination;
            }
        }
        return change;
    }
};
exports.BeverageService = BeverageService;
exports.BeverageService = BeverageService = __decorate([
    (0, tsyringe_1.autoInjectable)(),
    __metadata("design:paramtypes", [recipeRepository_1.RecipeRepository,
        ingredientsRepository_1.IngredientsRepository])
], BeverageService);
//# sourceMappingURL=beverageService.js.map