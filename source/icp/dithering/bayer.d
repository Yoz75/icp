module icp.dithering.bayer;

import cereslib.math;
import cereslib.algorythm;
import std.math : pow;

/// Bayer matrix
public struct Bayer
{
    private static immutable uint[] bayer0Level = [0, 2, 3, 1];

    private immutable uint level;
    private uint[] matrix;
    public immutable uint size;

    public this(uint level)
    {
        this.level = level;
        this.size = pow(2, level + 1);
        this.matrix = generateMatrixOfLevel(level);
    }

    /// Evaluate the **normalized** (0..1) matrix value
    /// Params:
    ///   index = the index of cell
    /// Returns: the normalized matrix value
    public float evaluateNormalized(int x, int y) const
    in
    {
        assert(x >= 0);
        assert(y >= 0);
        assert(x < size);
        assert(y < size);
    }
    do
    {
        immutable uint matrixValue = matrix[y * size + x];
        return (matrixValue + 0.5f) / (size * size);
    }

    private static uint[] generateMatrixOfLevel(uint level) pure
    {
        uint matrixSize = pow(2, level + 1);
        uint[] matrix = new uint[](matrixSize * matrixSize);

        if (level == 0)
        {
            matrix[] = bayer0Level[];
            return matrix;
        }

        uint currentSize = 2;
        matrix[0 .. 4] = bayer0Level[];

        while (currentSize < matrixSize)
        {
            immutable uint nextSize = currentSize * 2;

            uint[] nextMatrix = new uint[](nextSize * nextSize);

            foreach(y; 0..currentSize)
            {
                foreach(x; 0..currentSize)
                {
                    immutable uint value = matrix[y * currentSize + x];

                    nextMatrix[y * nextSize + x] = value * 4;

                    nextMatrix[y * nextSize + x + currentSize] = value * 4 + 2;

                    nextMatrix[(y + currentSize) * nextSize + x] = value * 4 + 3;

                    nextMatrix[(y + currentSize) * nextSize + x + currentSize] = value * 4 + 1;
                }
            }

            matrix = nextMatrix;
            currentSize = nextSize;
        }

        return matrix;
    }
}