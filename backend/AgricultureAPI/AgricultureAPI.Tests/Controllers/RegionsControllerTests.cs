using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using AgricultureAPI.Controllers;
using AgricultureAPI.Data;
using AgricultureAPI.Models;
using AgricultureAPI.Repositories;
using AgricultureAPI.Services;
using Moq;
using Xunit;

namespace AgricultureAPI.Tests.Controllers
{
    public class RegionsControllerTests
    {
        private readonly Mock<IRegionRepository> _mockRepository;
        private readonly RegionsController _controller;

        public RegionsControllerTests()
        {
            _mockRepository = new Mock<IRegionRepository>();
            _controller = new RegionsController(_mockRepository.Object);
        }

        [Fact]
        public async Task GetRegions_ReturnsOkResult_WithRegions()
        {
            // Arrange
            var regions = new List<Region>
            {
                new Region { Id = "centrale", Name = "Région Centrale" },
                new Region { Id = "kara", Name = "Région de la Kara" }
            };

            _mockRepository.Setup(repo => repo.GetAllAsync())
                .ReturnsAsync(regions);

            // Act
            var result = await _controller.GetRegions();

            // Assert
            var okResult = Assert.IsType<OkObjectResult>(result.Result);
            var returnedRegions = Assert.IsAssignableFrom<IEnumerable<Region>>(okResult.Value);
            Assert.Equal(2, returnedRegions.Count());
        }

        [Fact]
        public async Task GetRegion_WithValidId_ReturnsRegion()
        {
            // Arrange
            var regionId = "centrale";
            var region = new Region { Id = regionId, Name = "Région Centrale" };

            _mockRepository.Setup(repo => repo.GetByIdAsync(regionId))
                .ReturnsAsync(region);

            // Act
            var result = await _controller.GetRegion(regionId);

            // Assert
            var okResult = Assert.IsType<OkObjectResult>(result.Result);
            var returnedRegion = Assert.IsType<Region>(okResult.Value);
            Assert.Equal(regionId, returnedRegion.Id);
        }

        [Fact]
        public async Task GetRegion_WithInvalidId_ReturnsNotFound()
        {
            // Arrange
            var regionId = "nonexistent";
            _mockRepository.Setup(repo => repo.GetByIdAsync(regionId))
                .ReturnsAsync((Region?)null);

            // Act
            var result = await _controller.GetRegion(regionId);

            // Assert
            Assert.IsType<NotFoundResult>(result.Result);
        }

        [Fact]
        public async Task CreateRegion_WithValidRegion_ReturnsCreatedAtAction()
        {
            // Arrange
            var region = new Region { Id = "new-region", Name = "New Region" };
            _mockRepository.Setup(repo => repo.CreateAsync(It.IsAny<Region>()))
                .ReturnsAsync(region);

            // Act
            var result = await _controller.CreateRegion(region);

            // Assert
            var createdAtActionResult = Assert.IsType<CreatedAtActionResult>(result.Result);
            var returnedRegion = Assert.IsType<Region>(createdAtActionResult.Value);
            Assert.Equal(region.Id, returnedRegion.Id);
        }

        [Fact]
        public async Task UpdateRegion_WithValidId_ReturnsOkResult()
        {
            // Arrange
            var regionId = "centrale";
            var region = new Region { Id = regionId, Name = "Updated Region" };
            _mockRepository.Setup(repo => repo.UpdateAsync(It.IsAny<Region>()))
                .ReturnsAsync(region);

            // Act
            var result = await _controller.UpdateRegion(regionId, region);

            // Assert
            var okResult = Assert.IsType<OkObjectResult>(result.Result);
            var returnedRegion = Assert.IsType<Region>(okResult.Value);
            Assert.Equal(regionId, returnedRegion.Id);
        }

        [Fact]
        public async Task DeleteRegion_WithValidId_ReturnsNoContent()
        {
            // Arrange
            var regionId = "centrale";
            _mockRepository.Setup(repo => repo.DeleteAsync(regionId))
                .Returns(Task.CompletedTask);

            // Act
            var result = await _controller.DeleteRegion(regionId);

            // Assert
            Assert.IsType<NoContentResult>(result);
        }
    }
}
