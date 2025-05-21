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
exports.RecipeRepository = void 0;
const tsyringe_1 = require("tsyringe");
const Recipe_1 = require("../../domain/models/Recipe");
let RecipeRepository = class RecipeRepository {
    recipes;
    constructor() {
        this.recipes = {};
        this.initializeRecipes();
    }
    initializeRecipes() {
        this.AddRecipe('coffee', new Recipe_1.Recipe({ water: 1, coffee: 1 }), 2.50);
        this.AddRecipe('tea', new Recipe_1.Recipe({ water: 1, tea: 1 }), 2.00);
        this.AddRecipe('hotChocolate', new Recipe_1.Recipe({ milk: 2, chocolate: 1 }), 2.70);
        this.AddRecipe('latte', new Recipe_1.Recipe({ milk: 2, coffee: 1 }), 3.50);
        this.AddRecipe('cappuccino', new Recipe_1.Recipe({ milk: 1, coffee: 1 }), 3.20);
    }
    GetRecipe(beverageName) {
        return this.recipes[beverageName];
    }
    GetAllRecipes() {
        return this.recipes;
    }
    AddRecipe(beverageName, recipe, price) {
        this.recipes[beverageName] = { recipe, price };
    }
};
exports.RecipeRepository = RecipeRepository;
exports.RecipeRepository = RecipeRepository = __decorate([
    (0, tsyringe_1.singleton)(),
    __metadata("design:paramtypes", [])
], RecipeRepository);
//# sourceMappingURL=recipeRepository.js.map