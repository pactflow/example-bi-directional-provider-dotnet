using System;
using System.Collections.Generic;
using System.Linq;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Provider.Models;

namespace Provider.Controllers
{
    [Route("[controller]")]
    public class ProductsController : Controller
    {
        private static List<Product> products = new List<Product>
            {
                new Product { id = 2, type = "SNACK", name = "muesli bar"},
                new Product { id = 10, type = "LUNCH", name = "sandwich"},
                new Product { id = 27, type = "DINNER", name = "burger"}

            };

        // GET /products
        [HttpGet]
        public ActionResult<IEnumerable<Product>> GetProducts()
        {
            return products;
        }

        // GET /products/{id}
        [HttpGet("{id:int}")]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        [ProducesResponseType(StatusCodes.Status200OK)]
        public ActionResult<Product> GetProduct(int id)
        {
            var product = products.FirstOrDefault(product => product.id == id);

            if (product == null)
            {
                return new NotFoundResult();
            }

            return product;
        }
    }
}
