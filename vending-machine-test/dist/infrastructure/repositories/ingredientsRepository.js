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
exports.IngredientsRepository = void 0;
const Ingredient_1 = require("../../domain/models/Ingredient");
const tsyringe_1 = require("tsyringe");
let IngredientsRepository = class IngredientsRepository {
    ingredients;
    constructor() {
        this.ingredients = {};
        this.initializeIngredients();
    }
    initializeIngredients() {
        this.addIngredient('water', 100);
        this.addIngredient('sugar', 50);
        this.addIngredient('coffee', 30);
        this.addIngredient('tea', 30);
        this.addIngredient('milk', 20);
        this.addIngredient('iceCream', 10);
    }
    getIngredient(ingredientName) {
        return this.ingredients[ingredientName];
    }
    getAllIngredients() {
        return this.ingredients;
    }
    addIngredient(ingredientName, quantity) {
        this.ingredients[ingredientName] = new Ingredient_1.Ingredient(ingredientName, quantity);
    }
    restockIngredient(ingredientName, quantity) {
        const ingredient = this.ingredients[ingredientName];
        if (ingredient) {
            ingredient.refill(quantity);
        }
    }
};
exports.IngredientsRepository = IngredientsRepository;
exports.IngredientsRepository = IngredientsRepository = __decorate([
    (0, tsyringe_1.singleton)(),
    __metadata("design:paramtypes", [])
], IngredientsRepository);
//# sourceMappingURL=ingredientsRepository.js.map